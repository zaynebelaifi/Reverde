@echo off
for %%P in (8081 8082 8083 8084 8085 8086 8090) do for /f "tokens=5" %%Q in ('netstat -ano ^| findstr ":%%P .*LISTENING"') do taskkill /PID %%Q /F >nul 2>&1
echo Reverde services stopped.
