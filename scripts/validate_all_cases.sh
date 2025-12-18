#!/bin/bash
# validate_all_cases.sh
# Comprehensive validation script for all 20 MySQL performance degradation test cases

set -e

REPO_URL="https://github.com/mysql/mysql-server"
WORK_DIR="/tmp/mysql-validation"
REPORT_FILE="validation_results.txt"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize report
echo "MySQL Performance Degradation Test Suite Validation Report" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "=========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Clone repository if not exists
if [ ! -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}Cloning MySQL repository...${NC}"
    git clone "$REPO_URL" "$WORK_DIR"
    cd "$WORK_DIR"
    git fetch --all --tags
else
    echo -e "${YELLOW}Using existing repository at $WORK_DIR${NC}"
    cd "$WORK_DIR"
    git fetch --all --tags
fi

# Function to validate a single case
validate_case() {
    local case_id=$1
    local case_name=$2
    local commit=$3
    local file=$4
    local line=$5
    local version=$6
    
    echo ""
    echo "=========================================="
    echo "Validating $case_id: $case_name"
    echo "=========================================="
    
    {
        echo ""
        echo "### $case_id: $case_name"
        echo "**Commit**: $commit"
        echo "**File**: $file"
        echo "**Line**: $line"
        echo "**Version**: $version"
        echo ""
    } >> "$REPORT_FILE"
    
    local errors=0
    
    # Check if commit exists (try both short and potential long forms)
    echo -n "Checking commit existence... "
    if git cat-file -t "$commit" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        {
            echo "**Commit Validation**: ✓ PASS"
            git log -1 --format="- Date: %ai%n- Author: %an <%ae>%n- Subject: %s" "$commit"
            echo ""
        } >> "$REPORT_FILE"
    else
        echo -e "${RED}✗ FAIL - Commit does not exist${NC}"
        {
            echo "**Commit Validation**: ✗ FAIL"
            echo "- Error: Commit $commit not found in repository"
            echo "- Error Type: Type 1 (Data Fabrication)"
            echo ""
        } >> "$REPORT_FILE"
        ((errors++))
        return $errors
    fi
    
    # Check if file exists at commit
    echo -n "Checking file existence at commit... "
    if git cat-file -e "$commit:$file" 2>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        echo "**File Validation**: ✓ PASS" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    else
        echo -e "${RED}✗ FAIL - File does not exist at commit${NC}"
        {
            echo "**File Validation**: ✗ FAIL"
            echo "- Error: File $file not found at commit $commit"
            echo "- Error Type: Type 1 (Data Fabrication)"
            echo ""
        } >> "$REPORT_FILE"
        ((errors++))
        return $errors
    fi
    
    # Show file context around line
    echo -n "Checking line number and code context... "
    local total_lines=$(git show "$commit:$file" | wc -l)
    if [ $line -gt 0 ] && [ $line -le $total_lines ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        {
            echo "**Line Number Validation**: ✓ PASS (File has $total_lines lines)"
            echo ""
            echo "**Code Context** (Lines $((line-5)) to $((line+5))):"
            echo '```'
            git show "$commit:$file" | sed -n "$((line-5)),$((line+5))p" | nl -v $((line-5)) -w 6 -s "  "
            echo '```'
            echo ""
        } >> "$REPORT_FILE"
    else
        echo -e "${RED}✗ FAIL - Line number out of range${NC}"
        {
            echo "**Line Number Validation**: ✗ FAIL"
            echo "- Error: Line $line is out of range (file has $total_lines lines)"
            echo "- Error Type: Type 1 (Data Fabrication)"
            echo ""
        } >> "$REPORT_FILE"
        ((errors++))
    fi
    
    # Show commit diff summary
    echo "Checking commit diff... "
    {
        echo "**Commit Diff Summary**:"
        echo '```'
        git show "$commit" --stat -- "$file" 2>/dev/null || echo "No diff available"
        echo '```'
        echo ""
        echo "**Commit Diff Content** (first 50 lines):"
        echo '```'
        git show "$commit" -- "$file" 2>/dev/null | head -50 || echo "No diff available"
        echo '```'
        echo ""
    } >> "$REPORT_FILE"
    
    # Check version tags
    echo -n "Checking version tags... "
    local tags=$(git tag --contains "$commit" 2>/dev/null | grep -E "^mysql-$version" || true)
    if [ -n "$tags" ]; then
        echo -e "${GREEN}✓ Found matching tags${NC}"
        {
            echo "**Version Tag Validation**: ✓ PASS"
            echo "- Tags containing this commit:"
            echo "$tags" | sed 's/^/  - /'
            echo ""
        } >> "$REPORT_FILE"
    else
        echo -e "${YELLOW}⚠ WARNING - No exact version tag match found${NC}"
        {
            echo "**Version Tag Validation**: ⚠ WARNING"
            echo "- No tags matching version $version found containing this commit"
            echo "- This may indicate version mismatch (Error Type: Type 2)"
            echo ""
        } >> "$REPORT_FILE"
        ((errors++))
    fi
    
    echo "**Validation Result**: $errors error(s) found" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
    echo ""
    
    return $errors
}

# Main validation execution
echo ""
echo "=========================================="
echo "Starting Validation of All 20 Test Cases"
echo "=========================================="
echo ""

total_errors=0

# Validate all cases
validate_case "DEG-001" "ICU Library Performance" "7bb67e65" "sql/item_func.cc" "124" "8.0.35" || ((total_errors+=$?))
validate_case "DEG-002" "Startup IBD File Scan" "190ae9d8" "storage/innobase/srv/srv0start.cc" "2145" "8.0.39" || ((total_errors+=$?))
validate_case "DEG-003" "back_log Parameter Change" "f4e2a250" "sql/mysqld.cc" "4520" "8.4.0" || ((total_errors+=$?))
validate_case "DEG-004" "Range Scan Buffer Strategy" "9bd8dc92" "sql/sql_executor.cc" "3102" "8.0.38" || ((total_errors+=$?))
validate_case "DEG-005" "Windows OS_FILE_NORMAL" "3881f880" "storage/innobase/os/os0file.cc" "1560" "8.0.36" || ((total_errors+=$?))
validate_case "DEG-006" "Async Interface Memory Leak" "d16cccf0" "sql/rpl_async.cc" "89" "8.4.1" || ((total_errors+=$?))
validate_case "DEG-007" "NDB mt-scheduler Lock" "a1f761a2" "storage/ndb/src/kernel/vm/mt.cpp" "1450" "7.5" || ((total_errors+=$?))
validate_case "DEG-008" "Item_func Object Leak" "b63ecb62" "sql/item_cmpfunc.cc" "450" "8.0.37" || ((total_errors+=$?))
validate_case "DEG-009" "Router MySQLSession Leak" "c1bffd87" "router/src/mysql_rest_service.cc" "230" "8.0.36" || ((total_errors+=$?))
validate_case "DEG-010" "InnoDB Bulk Load Leak" "1a91522f" "storage/innobase/handler/ha_innodb.cc" "12800" "8.0.39" || ((total_errors+=$?))
validate_case "DEG-011" "NDB Send Buffer Concurrency" "e07873e0" "storage/ndb/src/kernel/vm/mt.cpp" "2100" "7.5.6" || ((total_errors+=$?))
validate_case "DEG-012" "Keyring Path Leak" "c87a69c5" "components/keyring_file/keyring_file.cc" "120" "8.0.37" || ((total_errors+=$?))
validate_case "DEG-013" "Dynamic Offload Strategy" "d4471e0e" "sql/sql_optimizer.cc" "850" "8.0.36" || ((total_errors+=$?))
validate_case "DEG-014" "Windows IO Cache Loop" "ae002904" "mysys/my_win_write.c" "45" "5.5" || ((total_errors+=$?))
validate_case "DEG-015" "MyISAM mmap Swap" "801deedc" "storage/myisam/mi_open.c" "600" "5.5" || ((total_errors+=$?))
validate_case "DEG-016" "Temp Table Concurrency" "20762059" "storage/innobase/srv/srv0srv.cc" "890" "5.7.6" || ((total_errors+=$?))
validate_case "DEG-017" "LOCK_QUERY_PLAN Contention" "19770943" "sql/sql_parse.cc" "5600" "5.7" || ((total_errors+=$?))
validate_case "DEG-018" "NDB Multi-table Update" "20593065" "sql/ha_ndbcluster.cc" "3200" "7.4" || ((total_errors+=$?))
validate_case "DEG-019" "NDB Event Buffer Leak" "20539452" "storage/ndb/src/ndbapi/NdbEventBuffer.cpp" "800" "7.4.5" || ((total_errors+=$?))
validate_case "DEG-020" "NDB GCI_OP Leak" "20651661" "storage/ndb/src/ndbapi/NdbEventBuffer.cpp" "950" "7.5" || ((total_errors+=$?))

# Summary
echo ""
echo "=========================================="
echo "Validation Complete"
echo "=========================================="
echo ""
{
    echo ""
    echo "## Validation Summary"
    echo ""
    echo "**Total Errors Found**: $total_errors"
    echo ""
    if [ $total_errors -eq 0 ]; then
        echo "✓ All test cases validated successfully!"
    else
        echo "⚠ $total_errors validation error(s) found. Review details above."
    fi
    echo ""
    echo "**Validation Date**: $(date)"
    echo "**Repository**: $REPO_URL"
    echo "**Working Directory**: $WORK_DIR"
} >> "$REPORT_FILE"

if [ $total_errors -eq 0 ]; then
    echo -e "${GREEN}✓ All test cases validated successfully!${NC}"
else
    echo -e "${RED}⚠ Found $total_errors validation error(s)${NC}"
    echo "See $REPORT_FILE for detailed results"
fi

echo ""
echo "Detailed report saved to: $REPORT_FILE"
