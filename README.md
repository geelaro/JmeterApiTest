# JmeterApiTest — JMeter 自动化性能测试项目

基于 Apache JMeter + Ant 的接口自动化测试框架，支持 JDBC 数据库测试和 HTTP API 测试。

## 项目结构

```
JmeterApiTest/
├── build.xml                    # Ant 构建脚本
├── build.properties.sample      # 构建配置模板 → 复制为 build.properties
├── jmx/
│   ├── MySQLTest.jmx            # JDBC 数据库测试计划
│   └── HttpApiTest.jmx          # HTTP API 测试计划
├── results/                     # 测试结果输出（不入库）
└── .gitignore
```

## 前置条件

| 工具  | 最低版本 | 说明                        |
|-------|---------|-----------------------------|
| JDK   | 8+      | 推荐 JDK 11 或 17 LTS        |
| JMeter| 5.6     | 下载 [apache-jmeter](https://jmeter.apache.org/) |
| Ant   | 1.10+   | `brew install ant` / `choco install ant` |
| ant-jmeter | 1.1.1 | 复制 `ant-jmeter-1.1.1.jar` 到 `$JMETER_HOME/lib/ext/` |

## 快速开始

### 1. 配置环境

```bash
# 复制配置模板
cp build.properties.sample build.properties

# 编辑 build.properties 设置 JMeter 路径
# jmeter.home=C:/tools/apache-jmeter-5.6
```

或通过环境变量：
```bash
export JMETER_HOME=/path/to/apache-jmeter-5.6
```

### 2. 安装 ant-jmeter 插件

从 https://github.com/jfifield/ant-jmeter 下载 `ant-jmeter-1.1.1.jar`，放入 `$JMETER_HOME/lib/ext/` 目录。

### 3. 运行测试

```bash
# 运行所有测试 (默认目标)
ant

# 仅运行测试，不生成 HTML 报告
ant test-only

# 运行指定测试脚本
ant -Djmx.pattern=HttpApiTest.jmx

# 参数化执行：自定义并发和循环次数
ant -Dthreads=100 -Dloops=10 -Drampup=20

# 指定数据库连接参数
ant -Ddb.url=jdbc:mysql://localhost:3306/mydb -Ddb.username=test -Ddb.password=secret

# 清理所有历史结果
ant clean-all
```

### 4. 查看报告

测试完成后，HTML 报告生成在 `results/{timestamp}/TestReport-{timestamp}.html`。

## 测试参数

所有测试计划支持通过 `-D` 参数动态配置，无需修改 JMX 文件：

| 参数         | 默认值  | 说明              |
|-------------|--------|-------------------|
| `threads`   | 10     | 并发线程数         |
| `rampup`    | 5      | 启动 ramp-up 时间（秒）|
| `loops`     | 1      | 循环次数           |
| `db.url`    | (必填)  | 数据库 JDBC URL    |
| `db.username`| (必填) | 数据库用户名        |
| `db.password`| (必填) | 数据库密码          |
| `api.host`  | httpbin.org | API 主机地址   |
| `api.port`  | 443    | API 端口          |
| `api.protocol`| https | API 协议         |
| `max_response_time`| 3000 | 最大响应时间 (ms)  |

### 示例：数据库测试

```bash
ant -Djmx.pattern=MySQLTest.jmx \
    -Ddb.url=jdbc:mysql://localhost:3306/company \
    -Ddb.username=test \
    -Ddb.password=test123 \
    -Dthreads=50 \
    -Dloops=5
```

### 示例：HTTP API 测试

```bash
ant -Djmx.pattern=HttpApiTest.jmx \
    -Dapi.host=api.example.com \
    -Dapi.port=443 \
    -Dapi.protocol=https \
    -Dthreads=100 \
    -Dloops=10
```

## CI/CD 集成

项目包含 GitHub Actions 工作流配置 (`.github/workflows/jmeter-test.yml`)。

在 GitHub 仓库中配置以下 Secrets：
- `JMETER_DB_URL`: 测试数据库连接地址
- `JMETER_DB_USERNAME`: 数据库用户名
- `JMETER_DB_PASSWORD`: 数据库密码

## 添加新测试

1. 在 `jmx/` 目录创建新的 `.jmx` 文件
2. 使用 `__P(参数名, 默认值)` 函数参数化配置
3. 为每个 Sampler 添加响应断言
4. 提交代码（确保不含敏感信息）
