# JmeterApiTest — JMeter 自动化性能测试项目

基于 Apache JMeter CLI 的接口性能测试框架，支持 JDBC 数据库测试和 HTTP API 测试，输出内置 Dashboard 报告。

## 项目结构

```
JmeterApiTest/
├── run.sh                  # 一键运行脚本 (Linux/Mac)
├── run.bat                 # 一键运行脚本 (Windows)
├── jmeter.env.sample       # 环境配置模板 → 复制为 jmeter.env
├── jmx/
│   ├── HttpApiTest.jmx     # HTTP API 测试计划
│   └── MySQLTest.jmx       # JDBC 数据库测试计划
├── results/                # 测试结果（不入库）
└── .gitignore
```

## 前置条件

| 工具   | 版本 | 说明                              |
|--------|------|-----------------------------------|
| JDK    | 8+   | 推荐 17 LTS                       |
| JMeter | 5.6+ | 下载 [apache-jmeter](https://jmeter.apache.org/) |

## 快速开始

### 1. 配置 JMeter 路径

```bash
# 方式一：设置环境变量
export JMETER_HOME=/opt/apache-jmeter

# 方式二：创建本地配置文件
cp jmeter.env.sample jmeter.env
# 编辑 jmeter.env 设置 JMETER_HOME
```

### 2. 运行测试

```bash
# Linux / Mac
./run.sh                        # 默认运行 HttpApiTest.jmx (10线程 1循环)
./run.sh HttpApiTest.jmx 100 10 # 100线程 10循环
./run.sh MySQLTest.jmx 50 5 10  # 50线程 5循环 10s启动

# Windows
run.bat
run.bat HttpApiTest.jmx 100 10

# 指定数据库连接 (MySQLTest)
DB_URL=jdbc:mysql://localhost:3306/company \
DB_USERNAME=test \
DB_PASSWORD=secret \
./run.sh MySQLTest.jmx 50 5

# 指定 API 目标
API_HOST=api.example.com ./run.sh HttpApiTest.jmx 100 10
```

### 3. 查看报告

测试完成后打开 `results/<testName>/<timestamp>/dashboard/index.html`。

JMeter Dashboard 包含 15+ 张图表：APDEX 评分、响应时间趋势图、p50/p90/p99 百分位、吞吐量曲线、错误分布等。

## 测试参数

通过环境变量或 JMX 文件中的 `__P(参数名, 默认值)` 动态配置：

| 参数               | 默认值       | 说明                |
|--------------------|-------------|---------------------|
| `threads`          | 10          | 并发线程数           |
| `rampup`           | 5           | 启动时间（秒）        |
| `loops`            | 1           | 循环次数             |
| `api.host`         | httpbin.org | HTTP API 主机       |
| `api.port`         | 443         | HTTP API 端口       |
| `api.protocol`     | https       | HTTP API 协议       |
| `max_response_time`| 3000        | 最大响应时间 (ms)    |
| `db.url`           | (必填)       | 数据库 JDBC URL     |
| `db.username`      | (必填)       | 数据库用户名         |
| `db.password`      | (必填)       | 数据库密码           |

## CI/CD

GitHub Actions 自动运行 (`.github/workflows/jmeter-test.yml`)：
- **Push / PR**: 自动运行 HTTP 测试，Dashboard 上传为 Artifact
- **workflow_dispatch**: 手动触发，可自定义线程数和循环次数
- **Secrets**: 配置 `JMETER_DB_URL/USERNAME/PASSWORD` 后自动运行 MySQL 测试

## 添加新测试

1. 在 `jmx/` 创建 `.jmx` 文件
2. 使用 `__P(参数名, 默认值)` 参数化配置
3. 为每个 Sampler 添加响应断言
4. 运行：`./run.sh your-test.jmx 10 1`
