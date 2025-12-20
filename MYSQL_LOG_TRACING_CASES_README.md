# MySQL日志溯源测试用例集

## 概述

本文件包含50个MySQL日志溯源测试用例（IDs 1-50），用于追踪MySQL日志消息到其源代码位置。

- **原始用例**: IDs 1-10 (由需求提供)
- **扩展用例**: IDs 11-50 (本次添加，位于`mysql_log_tracing_cases.json`)

## 文件说明

- `mysql_log_tracing_cases.json`: 包含40个新增测试用例（IDs 11-50）的JSON文件

## 用例覆盖范围

### InnoDB内核日志 (6个用例: IDs 11-16)
- 死锁检测 (lock0lock.cc)
- 锁等待超时 (lock0wait.cc)
- 表空间操作 (srv0tmp.cc)
- 事务冲突检测

### GTID复制日志 (5个用例: IDs 17-21)
- GTID持久化 (rpl_gtid_persist.cc)
- gtid_executed表操作
- GTID表压缩
- 内存不足处理

### 慢查询日志 (4个用例: IDs 22-25)
- 查询统计信息输出 (log.cc)
- 慢查询日志状态 (sys_vars.cc)
- 时间戳格式化

### 权限认证日志 (5个用例: IDs 26-30)
- 访问拒绝错误 (sql_authentication.cc)
- 证书验证失败
- 插件加载状态 (sql_auth_cache.cc)
- 认证插件错误

### NDB集群日志 (6个用例: IDs 31-36)
- 节点连接状态 (mt.cpp)
- 内存分配 (Emulator.cpp)
- 节点启动 (NdbcntrMain.cpp)
- 系统重启测试 (run_ndb_tests.pl)
- 节点强制关闭 (SimBlockList.cpp)

### Binlog相关日志 (4个用例: IDs 37-40)
- Binlog文件操作 (binlog.cc)
- 缓存大小限制
- 事件格式检测 (log_event.cc)
- RESET MASTER错误

### 性能模式日志 (3个用例: IDs 41-43)
- PFS初始化 (pfs.cc)
- 内存不足处理
- 工具分配失败 (pfs_instr.cc)

### 测试框架日志 (4个用例: IDs 44-47)
- 分区表测试 (partition_test.pl)
- 字符集测试 (charset_test.pl)
- 临时表测试 (temp_table_test.pl)
- DDL测试 (ddl_test.pl)

### 错误日志结构化输出 (3个用例: IDs 48-50)
- 文件操作错误 (log.cc)
- 复制线程状态 (rpl_replica.cc)
- 事件调度器 (events.cc)

## 用例格式

每个测试用例包含以下字段：

```json
{
  "id": <编号>,
  "输入": "<日志消息或测试命令>",
  "期望输出": {
    "文件位置": "<源码文件路径>",
    "上下文代码": "<日志输出的核心代码片段>",
    "函数与场景": "<触发函数、模块和具体场景描述>"
  }
}
```

## 版本覆盖

测试用例覆盖MySQL多个版本：
- MySQL 5.5.x
- MySQL 5.7.x
- MySQL 8.0.x
- NDB Cluster

## 日志类型

- 错误日志 (sql_print_error, LogErr ERROR_LEVEL)
- 警告日志 (sql_print_warning, LogErr WARNING_LEVEL)
- 信息日志 (sql_print_information, LogErr INFORMATION_LEVEL)
- 测试脚本命令日志 (print语句)
- InnoDB内核日志 (ib::error, ib::warn, ib::info)
- NDB日志 (g_eventLogger)
- 慢查询日志
- 结构化错误日志 ([ERROR] [MY-xxxxx])

## 使用方法

1. 读取JSON文件：
```python
import json
with open('mysql_log_tracing_cases.json', 'r', encoding='utf-8') as f:
    cases = json.load(f)
```

2. 查询特定日志消息的源码位置：
```python
for case in cases:
    if "deadlock" in case['输入'].lower():
        print(f"文件位置: {case['期望输出']['文件位置']}")
        print(f"场景: {case['期望输出']['函数与场景']}")
```

## 真实性保证

所有测试用例基于MySQL官方源码：
- 文件路径指向实际存在的源文件
- 日志消息来自真实的代码
- 上下文代码反映实际的日志输出方式
- 触发场景描述准确的执行路径

## 维护说明

- 用例ID连续递增，无断号
- 保持与原始10个用例相同的格式和风格
- 避免与原始用例重复的模块和场景
- 定期更新以适配新版本MySQL的代码变化
