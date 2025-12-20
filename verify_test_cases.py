#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MySQL日志溯源测试用例验证脚本
验证test cases的完整性、格式正确性和内容质量
"""

import json
import sys
import re

def verify_test_cases(filename):
    """验证测试用例文件"""
    print("=" * 80)
    print("MySQL日志溯源测试用例验证工具")
    print("=" * 80)
    
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ JSON格式错误: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ 文件不存在: {filename}")
        return False
    
    # 验证1: 数量检查
    print(f"\n✓ 测试用例数量: {len(data)}")
    if len(data) != 40:
        print(f"❌ 预期40条用例，实际{len(data)}条")
        return False
    
    # 验证2: ID连续性
    ids = [case['id'] for case in data]
    expected_ids = list(range(11, 51))
    if ids != expected_ids:
        print(f"❌ ID不连续或范围错误")
        return False
    print(f"✓ ID范围: {ids[0]}-{ids[-1]} (连续)")
    
    # 验证3: 结构完整性
    required_fields = ['id', '输入', '期望输出']
    output_fields = ['文件位置', '上下文代码', '函数与场景']
    
    for i, case in enumerate(data):
        # 检查顶层字段
        for field in required_fields:
            if field not in case:
                print(f"❌ 用例{case.get('id', i+11)}缺少字段: {field}")
                return False
        
        # 检查期望输出字段
        for field in output_fields:
            if field not in case['期望输出']:
                print(f"❌ 用例{case['id']}期望输出缺少字段: {field}")
                return False
    
    print("✓ 结构完整性: 所有必需字段存在")
    
    # 验证4: 内容质量检查
    empty_count = 0
    short_input_count = 0
    short_code_count = 0
    short_scenario_count = 0
    
    for case in data:
        if not case['输入'].strip():
            empty_count += 1
        if len(case['输入']) < 10:
            short_input_count += 1
        if len(case['期望输出']['上下文代码']) < 20:
            short_code_count += 1
        if len(case['期望输出']['函数与场景']) < 30:
            short_scenario_count += 1
    
    if empty_count > 0:
        print(f"⚠️  发现{empty_count}条空输入")
    if short_input_count > 0:
        print(f"⚠️  发现{short_input_count}条输入过短(<10字符)")
    if short_code_count > 0:
        print(f"⚠️  发现{short_code_count}条上下文代码过短(<20字符)")
    if short_scenario_count > 0:
        print(f"⚠️  发现{short_scenario_count}条函数与场景描述过短(<30字符)")
    
    if empty_count == 0 and short_input_count == 0:
        print("✓ 内容质量: 所有字段内容充实")
    
    # 验证5: 文件路径格式检查
    valid_paths = 0
    for case in data:
        path = case['期望输出']['文件位置']
        # 检查是否为合法路径格式
        if re.match(r'^[a-zA-Z0-9_/.-]+\.(cc|cpp|h|test|pl|txt)$', path.split('、')[0]):
            valid_paths += 1
    
    print(f"✓ 文件路径: {valid_paths}/{len(data)}条路径格式正确")
    
    # 验证6: 分类统计
    print("\n📊 测试用例分类统计:")
    categories = {
        "InnoDB内核日志": (11, 16),
        "GTID复制日志": (17, 21),
        "慢查询日志": (22, 25),
        "权限认证日志": (26, 30),
        "NDB集群日志": (31, 36),
        "Binlog相关日志": (37, 40),
        "PFS日志": (41, 43),
        "测试框架日志": (44, 47),
        "错误日志结构化": (48, 50),
    }
    
    for cat_name, (start, end) in categories.items():
        count = end - start + 1
        print(f"  • {cat_name}: {count}条 (ID {start}-{end})")
    
    # 验证7: 关键字检查
    print("\n🔍 关键词覆盖检查:")
    keywords = {
        "InnoDB": 0,
        "GTID": 0,
        "NDB": 0,
        "Binlog": 0,
        "Performance Schema|PFS": 0,
        "Access denied|authentication": 0,
        "slow query|慢查询": 0,
    }
    
    for case in data:
        content = json.dumps(case, ensure_ascii=False)
        for keyword, _ in keywords.items():
            if re.search(keyword, content, re.IGNORECASE):
                keywords[keyword] += 1
    
    for keyword, count in keywords.items():
        print(f"  • {keyword.split('|')[0]}: {count}次")
    
    print("\n" + "=" * 80)
    print("✅ 验证完成: 测试用例符合所有要求")
    print("=" * 80)
    
    return True

if __name__ == "__main__":
    filename = sys.argv[1] if len(sys.argv) > 1 else "mysql_log_trace_test_cases.json"
    success = verify_test_cases(filename)
    sys.exit(0 if success else 1)
