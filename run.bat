@echo off
REM ==========================================
REM JmeterApiTest — Windows 运行脚本
REM 用法: run.bat [jmx-file] [threads] [loops] [rampup]
REM ==========================================

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set JMX_DIR=%SCRIPT_DIR%jmx

set JMX_FILE=%1
if "%JMX_FILE%"=="" set JMX_FILE=HttpApiTest.jmx

set THREADS=%2
if "%THREADS%"=="" set THREADS=10

set LOOPS=%3
if "%LOOPS%"=="" set LOOPS=1

set RAMPUP=%4
if "%RAMPUP%"=="" set RAMPUP=5

REM JMETER_HOME: 环境变量 > jmeter.env 文件
if "%JMETER_HOME%"=="" (
    if exist "%SCRIPT_DIR%jmeter.env" (
        for /f "tokens=1,* delims==" %%a in (%SCRIPT_DIR%jmeter.env) do (
            set %%a=%%b
        )
    )
)

if "%JMETER_HOME%"=="" (
    echo ERROR: JMETER_HOME not set.
    echo   Create jmeter.env with: JMETER_HOME=C:\tools\apache-jmeter
    exit /b 1
)

set JMETER=%JMETER_HOME%\bin\jmeter.cmd

REM 时间戳 yyyyMMddHHmm
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set TIMESTAMP=%datetime:~0,12%

set JMX_NAME=%JMX_FILE:.jmx=%
set RESULT_DIR=%SCRIPT_DIR%results\%JMX_NAME%\%TIMESTAMP%

mkdir "%RESULT_DIR%" 2>nul

echo ==========================================
echo  JmeterApiTest
echo ==========================================
echo  脚本:    %JMX_FILE%
echo  线程:    %THREADS%
echo  循环:    %LOOPS%
echo  RampUp:  %RAMPUP%s
echo  输出:    %RESULT_DIR%
echo ==========================================

call "%JMETER%" -n ^
    -t "%JMX_DIR%\%JMX_FILE%" ^
    -l "%RESULT_DIR%\result.csv" ^
    -j "%RESULT_DIR%\jmeter.log" ^
    -e -o "%RESULT_DIR%\dashboard" ^
    -Jthreads=%THREADS% ^
    -Jrampup=%RAMPUP% ^
    -Jloops=%LOOPS% ^
    -Japi.host=httpbin.org ^
    -Japi.port=443 ^
    -Japi.protocol=https ^
    -Jmax_response_time=3000

echo.
echo ==========================================
echo  测试完成!
echo  Dashboard: %RESULT_DIR%\dashboard\index.html
echo ==========================================
endlocal
