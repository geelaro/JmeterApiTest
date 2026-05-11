#!/bin/bash
# ==========================================
# JmeterApiTest — JMeter CLI 一键运行脚本
# 用法: ./run.sh [jmx-file] [threads] [loops] [rampup]
# 示例:
#   ./run.sh                          # 默认运行 HttpApiTest.jmx
#   ./run.sh MySQLTest.jmx 50 10 5    # 50线程 10次循环 5秒启动
# ==========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JMX_DIR="${SCRIPT_DIR}/jmx"

# 参数: jmx文件 线程数 循环次数 rampup时间
JMX_FILE="${1:-HttpApiTest.jmx}"
THREADS="${2:-10}"
LOOPS="${3:-1}"
RAMPUP="${4:-5}"

# JMeter 路径: 环境变量 > 本地配置
if [ -z "$JMETER_HOME" ]; then
    if [ -f "${SCRIPT_DIR}/jmeter.env" ]; then
        source "${SCRIPT_DIR}/jmeter.env"
    fi
fi

if [ -z "$JMETER_HOME" ]; then
    echo "ERROR: 请设置 JMETER_HOME 环境变量或创建 jmeter.env 文件"
    echo "  export JMETER_HOME=/path/to/apache-jmeter"
    exit 1
fi

JMETER="${JMETER_HOME}/bin/jmeter"
TIMESTAMP=$(date +%Y%m%d%H%M)
RESULT_DIR="${SCRIPT_DIR}/results/${JMX_FILE%.jmx}/${TIMESTAMP}"

mkdir -p "${RESULT_DIR}"

echo "=========================================="
echo " JmeterApiTest"
echo "=========================================="
echo " 脚本:    ${JMX_FILE}"
echo " 线程:    ${THREADS}"
echo " 循环:    ${LOOPS}"
echo " RampUp:  ${RAMPUP}s"
echo " 输出:    ${RESULT_DIR}"
echo "=========================================="

# 运行 JMeter (非GUI模式)
"${JMETER}" -n \
    -t "${JMX_DIR}/${JMX_FILE}" \
    -l "${RESULT_DIR}/result.csv" \
    -j "${RESULT_DIR}/jmeter.log" \
    -e -o "${RESULT_DIR}/dashboard" \
    -Jthreads="${THREADS}" \
    -Jrampup="${RAMPUP}" \
    -Jloops="${LOOPS}" \
    -Jdb.url="${DB_URL:-}" \
    -Jdb.username="${DB_USERNAME:-}" \
    -Jdb.password="${DB_PASSWORD:-}" \
    -Japi.host="${API_HOST:-httpbin.org}" \
    -Japi.port="${API_PORT:-443}" \
    -Japi.protocol="${API_PROTOCOL:-https}" \
    -Jmax_response_time="${MAX_RESPONSE_TIME:-3000}"

echo ""
echo "=========================================="
echo " 测试完成!"
echo " Dashboard: file://${RESULT_DIR}/dashboard/index.html"
echo " JTL 数据: ${RESULT_DIR}/result.csv"
echo "=========================================="
