# MySQL Performance Degradation Test Suite - Validation Framework

> **Comprehensive validation framework for verifying 20 MySQL performance degradation test cases against official MySQL source code**

[![MySQL](https://img.shields.io/badge/MySQL-5.1%20to%208.4-blue)](https://github.com/mysql/mysql-server)
[![Status](https://img.shields.io/badge/Status-Ready%20to%20Use-green)]()
[![Documentation](https://img.shields.io/badge/Docs-Complete-brightgreen)]()

## 📋 Overview

This repository contains a production-ready validation framework designed to systematically verify the accuracy and authenticity of 20 MySQL performance degradation test cases. The framework validates:

- ✅ **Commit IDs** exist in the official MySQL repository
- ✅ **File paths** are correct at specified commits
- ✅ **Line numbers** point to relevant code
- ✅ **Code changes** match degradation descriptions
- ✅ **Version tags** align with baseline/degradation versions
- ✅ **Call stacks** reflect actual code structure
- ✅ **Performance impacts** are logically consistent
- ✅ **Fix proposals** address root causes

## 🎯 Quick Start

### Prerequisites

```bash
# Git 2.0 or higher
git --version

# ~10GB disk space for MySQL repository
df -h
```

### 3-Step Validation

```bash
# Step 1: Clone full MySQL repository (one-time setup)
git clone https://github.com/mysql/mysql-server.git /tmp/mysql-validation
cd /tmp/mysql-validation && git fetch --all --tags

# Step 2: Run automated validation
cd /path/to/this/repository
./scripts/validate_all_cases.sh

# Step 3: Review results
cat validation_results.txt
```

**That's it!** The framework will validate all 20 test cases and generate a detailed report.

## 📚 Documentation

### Core Documents

| Document | Size | Purpose |
|----------|------|---------|
| [**VALIDATION_FRAMEWORK_SUMMARY.md**](VALIDATION_FRAMEWORK_SUMMARY.md) | 16KB | 📖 **START HERE** - Executive summary and quick reference |
| [**VALIDATION_README.md**](VALIDATION_README.md) | 12KB | 📘 Complete user guide with setup and usage |
| [**DEGRADATION_VALIDATION_REPORT.md**](DEGRADATION_VALIDATION_REPORT.md) | 30KB | 📋 Detailed methodology and test case information |
| [**VALIDATION_EXPECTED_ISSUES.md**](VALIDATION_EXPECTED_ISSUES.md) | 12KB | ⚠️ Expected challenges and risk assessment |
| [**EXAMPLE_VALIDATION_OUTPUT.md**](EXAMPLE_VALIDATION_OUTPUT.md) | 13KB | 📊 Sample validation outputs and interpretation |

### Scripts

| Script | Size | Purpose |
|--------|------|---------|
| [**scripts/validate_all_cases.sh**](scripts/validate_all_cases.sh) | 9KB | 🔧 Batch validation of all 20 test cases |
| [**scripts/quick_verify.sh**](scripts/quick_verify.sh) | 3KB | ⚡ Fast single-commit verification |

## 🔍 What Gets Validated

### 20 Test Cases Covering

**Storage Engines:**
- InnoDB (6 cases): Startup, bulk load, concurrency, IO optimization
- NDB Cluster (7 cases): Scheduler locks, buffer management, event handling
- MyISAM (2 cases): Compressed table memory management

**Core Components:**
- Query Optimizer (3 cases): Range scan buffers, offload strategy
- Replication (2 cases): Async interface, object lifecycle
- Connection Handling (2 cases): back_log parameter, query plan locks

**Issue Types:**
- Memory Leaks (9 cases): Resource not released, object leaks
- CPU/Performance (7 cases): Lock contention, inefficient algorithms
- IO Throughput (3 cases): File operations, cache management
- Data Correctness (1 case): Multi-table update consistency
- Thread Hang (1 case): Concurrency ticket handling

**MySQL Versions:**
- MySQL 8.x (13 cases): Latest version issues
- MySQL 5.7.x (2 cases): Query plan, temp table
- MySQL 5.5.x (2 cases): IO cache, MyISAM mmap
- NDB 7.x (5 cases): NDB cluster specific

## 🚀 Usage Examples

### Example 1: Full Validation

```bash
# Run complete validation on all 20 cases
./scripts/validate_all_cases.sh

# Output includes:
# - Commit validation for each case
# - File existence checks
# - Line number verification
# - Code context (11 lines around specified line)
# - Commit diffs (first 50 lines)
# - Version tag validation
# - Summary with error counts
```

### Example 2: Quick Check

```bash
# Verify a specific test case quickly
./scripts/quick_verify.sh 7bb67e65 sql/item_func.cc 124

# Shows:
# - Commit information
# - File validation
# - Code context with highlighting
# - Full commit diff
# - Version tags
```

### Example 3: Manual Investigation

```bash
# Manual validation for deep analysis
cd /tmp/mysql-validation

# Check commit
git show 7bb67e65 --stat

# View file at commit
git show 7bb67e65:sql/item_func.cc | sed -n '119,129p'

# See diff
git show 7bb67e65 -- sql/item_func.cc

# Check versions
git tag --contains 7bb67e65 | grep "8.0"
```

## 📊 Expected Results

Based on comprehensive analysis of the test suite:

### Validation Success Rate

| Outcome | Expected Count | Percentage |
|---------|----------------|------------|
| ✅ Fully Validated | 5-7 cases | 25-35% |
| ⚠️ Validated with Warnings | 8-10 cases | 40-50% |
| ❌ Major Issues | 4-6 cases | 20-30% |
| ⛔ Cannot Validate | 2-3 cases | 10-15% |

### Common Issues

1. **Truncated Commit IDs** (100% of cases)
   - All use 8-character short hashes
   - Need expansion to full 40-character hashes
   - Risk of hash collisions in large repos

2. **Bug Numbers as Commits** (5-7 cases)
   - Cases DEG-016 through DEG-020
   - Use MySQL bug IDs instead of Git commits
   - Require conversion to actual commit hashes

3. **Line Number Drift** (40-50% of cases)
   - Code evolves, line numbers shift
   - Typical drift: ±5 to ±20 lines
   - Need verification of actual code location

4. **Version Mismatches** (20-30% of cases)
   - Commits may be in different versions
   - Backports complicate version mapping
   - Require careful version tag verification

5. **File Path Changes** (10-15% of cases)
   - Old versions (5.5.x, 5.7.x) have different structure
   - Refactoring moves files
   - Need git log --follow for tracking

## 🎓 Framework Features

### Validation Capabilities

- ✅ **Commit Validation**: Verifies existence in official MySQL repo
- ✅ **File Verification**: Checks paths at specific commits
- ✅ **Line Number Check**: Validates line is within file bounds
- ✅ **Code Context**: Shows ±5 lines around specified line
- ✅ **Diff Analysis**: Displays actual commit changes
- ✅ **Version Mapping**: Confirms version tag relationships
- ✅ **Error Classification**: 5 types of errors identified
- ✅ **Batch Processing**: Validates all cases in one run
- ✅ **Quick Checks**: Fast single-case verification
- ✅ **Color Output**: Easy-to-read console output
- ✅ **Detailed Reports**: Structured validation results

### Error Classification

The framework classifies errors into 5 types:

| Type | Description | Example |
|------|-------------|---------|
| Type 1 | **Data Fabrication** | Commit doesn't exist, file path wrong |
| Type 2 | **Association Error** | Commit not in stated version, file not in commit |
| Type 3 | **Logic Error** | Call stack incorrect, illogical fix proposal |
| Type 4 | **Description Ambiguity** | Change description vague or inconsistent |
| Type 5 | **Cannot Verify** | Valid commit but version not public |

## 🛠️ Advanced Usage

### Custom Validation

```bash
# Validate specific cases only
for case_id in DEG-001 DEG-005 DEG-010; do
    ./scripts/quick_verify.sh ...
done

# Extract only errors from results
grep "ERROR\|FAIL" validation_results.txt > errors_only.txt

# Count errors by type
grep "Type [1-5]" validation_results.txt | sort | uniq -c
```

### Search Related Commits

```bash
cd /tmp/mysql-validation

# Find commits by keyword
git log --all --grep="ICU" --oneline
git log --all --grep="WL#8619" --oneline

# Find commits modifying file
git log --all --oneline -- sql/item_func.cc | head -20

# Find commits in version range
git log mysql-8.0.34..mysql-8.0.35 --oneline
```

### Convert Bug Numbers

```bash
# Some cases use bug numbers instead of commits
# Example: Bug #20762059

# Search in commit messages
git log --all --grep="20762059" --oneline
git log --all --grep="Bug#20762059" --oneline

# Search in commit content
git log --all -S "20762059" --oneline
```

## 📦 What's Included

### Documentation (93KB across 5 files)

```
📄 VALIDATION_FRAMEWORK_SUMMARY.md     (16KB) - Executive summary
📄 VALIDATION_README.md                (12KB) - Complete user guide  
📄 DEGRADATION_VALIDATION_REPORT.md    (30KB) - Detailed methodology
📄 VALIDATION_EXPECTED_ISSUES.md       (12KB) - Risk assessment
📄 EXAMPLE_VALIDATION_OUTPUT.md        (13KB) - Sample outputs
```

### Scripts (12KB across 2 files)

```
🔧 scripts/validate_all_cases.sh       (9KB)  - Batch validation
⚡ scripts/quick_verify.sh             (3KB)  - Quick verification
```

### Total Framework

- **7 files** providing complete validation solution
- **~95KB** of comprehensive documentation and scripts
- **20 test cases** covered systematically
- **8 validation fields** per case
- **5 error types** for classification

## 💡 Use Cases

### 1. Research Validation

**Scenario**: Verify test suite before publishing research paper

**Steps**:
1. Run full validation
2. Review and correct errors
3. Re-validate to confirm
4. Document validation status in paper

**Benefit**: Peer-reviewed, validated findings

### 2. Performance Investigation

**Scenario**: Engineer investigating specific performance regression

**Steps**:
1. Identify relevant test case
2. Run quick verification
3. Review commit diff and context
4. Use findings in root cause analysis

**Benefit**: Confirmed regression evidence

### 3. Quality Assurance

**Scenario**: QA team maintaining test suite quality

**Steps**:
1. Run validation monthly
2. Compare with previous results
3. Update test cases as needed
4. Track validation history

**Benefit**: Continuously updated test suite

### 4. Security Audit

**Scenario**: Security team auditing memory leaks

**Steps**:
1. Filter memory leak cases (9 total)
2. Validate each thoroughly
3. Confirm security implications
4. Prioritize fixes

**Benefit**: Risk-prioritized security issues

## 🎯 Best Practices

### For Validators

1. ✅ **Start with Recent Versions**: Validate 8.0+ cases first (higher success rate)
2. ✅ **Use Full Clone**: Don't use shallow clones (missing history)
3. ✅ **Prioritize Critical Cases**: Focus on "Must Identify" cases (17 of 20)
4. ✅ **Document Thoroughly**: Keep detailed validation logs
5. ✅ **Cross-Reference**: Check MySQL bug tracker and release notes

### For Test Suite Creators

1. ✅ **Use Full Commit Hashes**: Always provide 40-character hashes
2. ✅ **Specify Exact Versions**: Use tags (mysql-8.0.35) not ranges (8.0.3x)
3. ✅ **Verify Line Numbers**: Check at specific commit, not just version
4. ✅ **Include Commit Links**: Provide GitHub URLs for easy access
5. ✅ **Distinguish IDs**: Clearly mark bug numbers vs commit hashes

### For Framework Users

1. ✅ **Clone Complete Repo**: Get full history, not shallow
2. ✅ **Fetch All Branches**: Include remote branches and tags
3. ✅ **Save Results**: Keep logs for comparison over time
4. ✅ **Report Issues**: Document framework bugs or improvements
5. ✅ **Update Regularly**: Re-validate as new versions release

## 🐛 Troubleshooting

### Issue: "Commit not found"

**Solutions**:
```bash
# Try finding by partial hash
git log --all --oneline | grep abc12345

# Fetch complete history
git fetch --unshallow

# Search all branches
git log --all --oneline | grep "keyword"
```

### Issue: "File not found"

**Solutions**:
```bash
# Track file across renames
git log --follow --all -- path/to/file.cc

# Search for similar names
find . -name "*partial_name*"

# Check nearby commits
git show HEAD~5:path/to/file.cc
```

### Issue: "Line number out of range"

**Solutions**:
```bash
# Check file line count
git show commit:file | wc -l

# Search for code pattern
git show commit:file | grep -n "pattern"

# View around expected area
git show commit:file | sed -n '100,200p'
```

## 📈 Success Metrics

### What Success Looks Like

- ✅ 80%+ of test cases validated (fully or with minor warnings)
- ✅ All Type 1 errors (data fabrication) identified and corrected
- ✅ Version mismatches resolved
- ✅ Line numbers adjusted for code drift
- ✅ Bug numbers converted to commit hashes
- ✅ Validation report generated with < 5% cannot-verify rate

### Continuous Improvement

- 📊 Track validation success rate over time
- 📊 Monitor error types and trends
- 📊 Update test cases with new MySQL versions
- 📊 Refine validation methodology based on findings
- 📊 Expand test suite with validated cases

## 🤝 Contributing

We welcome contributions to improve this validation framework:

### Areas for Contribution

- 🔧 Script enhancements and optimizations
- 📝 Documentation improvements
- 🐛 Bug reports and fixes
- ✨ New validation checks
- 📊 Additional test cases
- 🎨 Output formatting improvements

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Test thoroughly
5. Submit a pull request

## 📞 Support

### Getting Help

1. **Documentation**: Start with [VALIDATION_FRAMEWORK_SUMMARY.md](VALIDATION_FRAMEWORK_SUMMARY.md)
2. **Examples**: Check [EXAMPLE_VALIDATION_OUTPUT.md](EXAMPLE_VALIDATION_OUTPUT.md)
3. **Troubleshooting**: See [VALIDATION_README.md](VALIDATION_README.md)
4. **Issues**: Review [VALIDATION_EXPECTED_ISSUES.md](VALIDATION_EXPECTED_ISSUES.md)
5. **Questions**: Open an issue in the repository

### External Resources

- 🌐 [MySQL Official Repository](https://github.com/mysql/mysql-server)
- 🐛 [MySQL Bug Tracker](https://bugs.mysql.com/)
- 📖 [MySQL Documentation](https://dev.mysql.com/doc/)
- 📚 [Git Documentation](https://git-scm.com/doc)

## 📜 License

This validation framework follows the same license as the MySQL Server project.

## 🙏 Acknowledgments

- MySQL Development Team for maintaining comprehensive commit history
- Git for powerful version control capabilities
- Bash scripting for automation possibilities
- Open source community for validation methodologies

---

## 🎉 Ready to Start?

1. **Read the [Summary](VALIDATION_FRAMEWORK_SUMMARY.md)** - 5 minutes
2. **Clone MySQL repo** - 15-20 minutes
3. **Run validation** - 10-15 minutes
4. **Review results** - 10-30 minutes

**Total time**: ~45-70 minutes for complete validation of all 20 cases

---

**Framework Version**: 1.0  
**Release Date**: 2025-12-18  
**Status**: ✅ Production Ready  
**Maintained by**: MySQL Performance Analysis Team

**Questions?** Start with the [VALIDATION_FRAMEWORK_SUMMARY.md](VALIDATION_FRAMEWORK_SUMMARY.md)
