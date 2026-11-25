@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Stop-Reverde.ps1" %*
