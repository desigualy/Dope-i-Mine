@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0test_all_local_gates.ps1" %*
