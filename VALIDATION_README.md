# MySQL Performance Degradation Test Suite Validation Framework

## Overview

This validation framework is designed to verify the accuracy and authenticity of 20 MySQL performance degradation test cases against the official MySQL Server source code repository. The framework ensures that all reported performance issues, commits, file paths, line numbers, and fixes are based on real MySQL source code history.

## Purpose

The validation framework addresses the need to:

1. **Verify Data Authenticity**: Confirm that all commit IDs, version numbers, file paths, and line numbers are accurate
2. **Validate Code Changes**: Ensure that "Change Type" descriptions match actual commit diffs
3. **Check Logical Consistency**: Verify that degradation results, call stacks, and fix proposals are logically sound
4. **Ensure Completeness**: Validate every field of every test case without omission

## Test Suite Overview

The test suite contains 20 performance degradation cases (DEG-001 through DEG-020) covering:

- **Storage Engines**: InnoDB, MyISAM, NDB
- **Core Components**: Query optimizer, replication, connection handling, startup logic
- **Issue Types**: Memory leaks, CPU consumption, IO throughput, lock contention, data inconsistency
- **MySQL Versions**: 5.1.x through 8.4.x

### Test Case Statistics

- **Total Cases**: 20
- **High Priority Cases**: 11 (marked with ✅ "Must Identify")
- **Memory Leak Cases**: 9
- **Performance Degradation Cases**: 7
- **Data Correctness Cases**: 2
- **Thread Safety Cases**: 2

## Files in This Framework

### Documentation

1. **DEGRADATION_VALIDATION_REPORT.md**: Comprehensive validation report template with detailed validation methodology, test case information, and validation commands for each case

2. **VALIDATION_README.md** (this file): Framework overview and usage guide

### Scripts

3. **scripts/validate_all_cases.sh**: Automated validation script for all 20 test cases
   - Validates commit existence
   - Checks file paths
   - Verifies line numbers
   - Shows code context
   - Displays commit diffs
   - Checks version tags
   - Generates detailed report

4. **scripts/quick_verify.sh**: Quick verification tool for individual commits
   - Fast single-commit validation
   - Shows commit details, file content, and diff
   - Color-coded output for easy reading

## Prerequisites

### System Requirements

- **Git**: Version 2.0 or higher
- **Bash**: Version 4.0 or higher
- **Disk Space**: ~10GB for complete MySQL repository clone
- **Network**: Internet connection to clone MySQL repository

### Required Tools

```bash
# Verify git is installed
git --version

# Verify bash is installed
bash --version
```

## Usage

### Option 1: Automated Full Validation

Run the comprehensive validation script to check all 20 test cases:

```bash
# Make script executable
chmod +x scripts/validate_all_cases.sh

# Run full validation
./scripts/validate_all_cases.sh
```

The script will:
1. Clone the official MySQL repository (if not already present)
2. Validate all 20 test cases sequentially
3. Generate a detailed report: `validation_results.txt`
4. Display summary with error count

**Output**: The script creates `validation_results.txt` with:
- Commit validation results
- File existence checks
- Line number validation
- Code context (11 lines around specified line)
- Commit diff content
- Version tag verification
- Error classification

### Option 2: Quick Single Commit Verification

Verify a specific commit quickly:

```bash
# Make script executable
chmod +x scripts/quick_verify.sh

# Verify a commit
./scripts/quick_verify.sh <commit_id> <file_path> [line_number]

# Example: Verify DEG-001
./scripts/quick_verify.sh 7bb67e65 sql/item_func.cc 124
```

**Output**: Displays:
- Commit information (date, author, subject)
- File validation status
- Code context around specified line (highlighted)
- Commit diff (first 100 lines)
- Version tags containing the commit
- Branches containing the commit

### Option 3: Manual Validation

Use the commands provided in DEGRADATION_VALIDATION_REPORT.md for manual validation:

```bash
# Clone MySQL repository
git clone https://github.com/mysql/mysql-server.git
cd mysql-server

# Fetch all branches and tags
git fetch --all --tags

# Check if commit exists
git cat-file -t 7bb67e65

# View commit details
git show 7bb67e65 --stat

# View file at commit
git show 7bb67e65:sql/item_func.cc | sed -n '119,129p' | nl -v 119

# View commit diff
git show 7bb67e65 -- sql/item_func.cc

# Check version tags
git tag --contains 7bb67e65 | grep "8.0"
```

## Validation Workflow

### Step 1: Initial Setup

```bash
# Clone repository (one-time setup)
git clone https://github.com/mysql/mysql-server.git /tmp/mysql-validation
cd /tmp/mysql-validation

# Fetch all history
git fetch --all --tags
```

### Step 2: Validate Each Test Case

For each of the 20 test cases, perform these checks:

1. **Commit Validation**
   - Verify commit ID exists in repository
   - Check commit date and author
   - Verify commit belongs to correct version

2. **File Path Validation**
   - Confirm file exists at specified commit
   - Check if file path has changed across versions
   - Verify file is relevant to described issue

3. **Line Number Validation**
   - Ensure line number is within file bounds
   - Verify line contains relevant code
   - Check code context matches change description

4. **Diff Validation**
   - Review actual commit diff
   - Confirm "Change Type" description matches diff
   - Verify changed code relates to degradation

5. **Version Tag Validation**
   - Check commit is in correct version branch
   - Verify baseline and degradation versions
   - Confirm version timeline is logical

### Step 3: Error Classification

Classify any errors found into these types:

- **Type 1 - Data Fabrication**: Commit doesn't exist, file path wrong, invalid line number
- **Type 2 - Association Error**: Commit doesn't match version, file not in commit, line doesn't match change
- **Type 3 - Logic Error**: Call stack incorrect, degradation result illogical, fix proposal invalid
- **Type 4 - Description Ambiguity**: Change type vague, inconsistent with diff
- **Type 5 - Cannot Verify**: Commit valid but version not public, file exists but line has no code

### Step 4: Generate Report

Document findings in structured format:

```markdown
| Case ID | Error Field | Error Type | Error Details | Verification Evidence |
|---------|-------------|------------|---------------|----------------------|
| DEG-XXX | Commit ID | Type 1 | Commit not found | git show: 404 error |
```

## Expected Validation Results

### Likely Issues to Find

Based on the test suite structure, common issues may include:

1. **Truncated Commit IDs**: Many commit IDs appear to be 8-character short hashes; full 40-character hashes needed for verification

2. **Line Number Drift**: Line numbers may shift between versions due to code evolution

3. **File Path Changes**: MySQL has undergone refactoring; some file paths may have moved

4. **Version Ambiguity**: Some commits may exist in multiple branches

5. **Worklog References**: Internal worklog numbers (WL#) may not be directly visible in public commits

### Success Criteria

A test case passes validation when:
- ✓ Commit ID exists and is queryable
- ✓ File path is correct at specified commit
- ✓ Line number is within file bounds
- ✓ Code context matches change description
- ✓ Commit diff supports degradation claim
- ✓ Version tags align with baseline/degradation versions

## Example Validation Session

```bash
# Start validation
cd /tmp/mysql-validation

# Case DEG-001: ICU Library Performance
echo "Validating DEG-001..."

# Check commit
git show 7bb67e65 --stat
# Expected: Shows commit details if exists, or error if not

# Check file
git show 7bb67e65:sql/item_func.cc | head -150
# Expected: Shows file content if exists

# Check line 124
git show 7bb67e65:sql/item_func.cc | sed -n '119,129p' | nl -v 119
# Expected: Shows code around line 124

# Check diff
git show 7bb67e65 -- sql/item_func.cc
# Expected: Shows what changed in this file

# Check version
git tag --contains 7bb67e65 | grep "8.0.35"
# Expected: Shows if commit is in version 8.0.35

# Document results
echo "DEG-001: [PASS/FAIL] - [reason]" >> validation_log.txt
```

## Troubleshooting

### Issue: "Commit not found"

**Possible Causes**:
- Commit ID is truncated (only 8 chars instead of 40)
- Commit is in a different branch
- Repository history is incomplete

**Solutions**:
```bash
# Try to find commit by partial hash
git log --all --oneline | grep 7bb67e65

# Fetch complete history
git fetch --unshallow

# Search in all branches
git log --all --oneline | grep "ICU\|regex"
```

### Issue: "File not found at commit"

**Possible Causes**:
- File path has changed
- File was renamed
- File doesn't exist in that version

**Solutions**:
```bash
# Track file history across renames
git log --follow --all -- sql/item_func.cc

# Search for similar file names
find . -name "*item_func*"

# Check file in nearby commits
git show HEAD~10:sql/item_func.cc
```

### Issue: "Line number out of range"

**Possible Causes**:
- Line number has drifted due to code changes
- Wrong commit being checked
- File was refactored

**Solutions**:
```bash
# Check total line count
git show 7bb67e65:sql/item_func.cc | wc -l

# Search for relevant code
git show 7bb67e65:sql/item_func.cc | grep -n "ICU\|regex"

# View entire function
git show 7bb67e65:sql/item_func.cc | less
```

## Reporting Results

### For Successful Validation

Document in `validation_results.txt`:

```
DEG-001: ICU Library Performance
Status: ✓ VALIDATED
- Commit 7bb67e65 exists and is valid
- File sql/item_func.cc exists at commit
- Line 124 contains relevant ICU regex code
- Commit is in version 8.0.35 branch
- Change description matches diff
```

### For Failed Validation

Document with error type and evidence:

```
DEG-001: ICU Library Performance
Status: ✗ FAILED
- Error Type: Type 1 (Data Fabrication)
- Error: Commit 7bb67e65 not found in repository
- Evidence: `git show 7bb67e65` returns "fatal: bad object"
- Recommendation: Verify correct commit ID or search for related commits
```

## Advanced Usage

### Batch Validation with Parallel Processing

```bash
# Validate multiple cases in parallel
for case_id in {001..020}; do
    ./scripts/quick_verify.sh DEG-$case_id &
done
wait
```

### Custom Validation Report

```bash
# Generate custom report format
./scripts/validate_all_cases.sh | tee custom_report.txt

# Extract only errors
grep "ERROR\|FAIL" validation_results.txt > errors_only.txt

# Count errors by type
grep "Type 1\|Type 2\|Type 3" validation_results.txt | sort | uniq -c
```

### Search for Related Commits

```bash
# Find commits related to a topic
git log --all --grep="ICU" --oneline
git log --all --grep="regex" --oneline
git log --all --grep="WL#8619" --oneline

# Find commits by file
git log --all --oneline -- sql/item_func.cc | head -20

# Find commits in version range
git log mysql-8.0.34..mysql-8.0.35 --oneline
```

## Best Practices

1. **Start with High Priority Cases**: Focus on cases marked with ✅ "Must Identify" first

2. **Verify Full Commit Hashes**: Always expand 8-character hashes to full 40-character hashes

3. **Check Multiple Sources**: Cross-reference with MySQL bug tracker and release notes

4. **Document Everything**: Keep detailed notes of all findings and validation steps

5. **Use Version Control**: Track your validation progress with git

6. **Regular Updates**: Re-validate periodically as new MySQL versions are released

## Contributing

To improve this validation framework:

1. Report any bugs or issues in the validation scripts
2. Suggest additional validation checks
3. Provide corrections for any test case errors found
4. Share improved validation methodologies

## References

- **MySQL Source Repository**: https://github.com/mysql/mysql-server
- **MySQL Bug Tracker**: https://bugs.mysql.com/
- **MySQL Release Notes**: https://dev.mysql.com/doc/relnotes/mysql/
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **MySQL Worklog**: https://dev.mysql.com/worklog/

## License

This validation framework follows the same license as the MySQL Server project.

---

**Framework Version**: 1.0  
**Last Updated**: 2025-12-18  
**Maintainer**: MySQL Performance Analysis Team
