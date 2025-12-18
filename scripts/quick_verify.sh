#!/bin/bash
# quick_verify.sh - Quick verification of a single commit
# Usage: ./quick_verify.sh <commit_id> <file_path> [line_number]

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <commit_id> <file_path> [line_number]"
    echo ""
    echo "Example: $0 7bb67e65 sql/item_func.cc 124"
    exit 1
fi

COMMIT=$1
FILE=$2
LINE=${3:-0}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}MySQL Commit Quick Verification${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Verify commit
echo -e "${YELLOW}=== Commit Information ===${NC}"
if git log -1 --stat "$COMMIT" 2>/dev/null; then
    echo -e "${GREEN}✓ Commit exists${NC}"
else
    echo -e "${RED}✗ ERROR: Commit not found${NC}"
    exit 1
fi

# Verify file
echo ""
echo -e "${YELLOW}=== File Verification ===${NC}"
if git cat-file -e "$COMMIT:$FILE" 2>/dev/null; then
    echo -e "${GREEN}✓ File exists at commit${NC}"
    
    # Get file line count
    local total_lines=$(git show "$COMMIT:$FILE" | wc -l)
    echo "  File has $total_lines lines"
    
    if [ $LINE -gt 0 ]; then
        if [ $LINE -le $total_lines ]; then
            echo -e "${GREEN}✓ Line $LINE is within file range${NC}"
            echo ""
            echo -e "${YELLOW}=== Code Context (Lines $((LINE-10)) to $((LINE+10))) ===${NC}"
            git show "$COMMIT:$FILE" | sed -n "$((LINE-10)),$((LINE+10))p" | nl -v $((LINE-10)) -w 6 -s "  " | \
                awk -v line=$LINE '{if (NR==11) print "\033[1;32m" $0 "\033[0m"; else print $0}'
        else
            echo -e "${RED}✗ Line $LINE is out of range (file has $total_lines lines)${NC}"
        fi
    fi
else
    echo -e "${RED}✗ ERROR: File does not exist at commit${NC}"
    exit 1
fi

# Show diff
echo ""
echo -e "${YELLOW}=== Commit Diff (first 100 lines) ===${NC}"
git show "$COMMIT" -- "$FILE" 2>/dev/null | head -100

# Check version tags
echo ""
echo -e "${YELLOW}=== Version Tags Containing This Commit ===${NC}"
local tags=$(git tag --contains "$COMMIT" 2>/dev/null | head -10)
if [ -n "$tags" ]; then
    echo "$tags"
else
    echo "No release tags found containing this commit"
fi

# Show branches containing commit
echo ""
echo -e "${YELLOW}=== Branches Containing This Commit ===${NC}"
git branch -a --contains "$COMMIT" 2>/dev/null | head -10

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Verification Complete${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
