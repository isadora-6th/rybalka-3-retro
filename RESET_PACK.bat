@echo off
cd /d "%~dp0"
echo ============================================
echo   RESET PACK - Clean and re-download
echo ============================================
echo.
echo This will DELETE everything in:
echo   - instances\1.4.7\.minecraft\texturepacks\
echo   - instances\1.4.7\.minecraft\mods\
echo   - instances\1.4.7\.minecraft\coremods\
echo   - instances\1.4.7\.minecraft\config\
echo   - instances\1.4.7\.minecraft\resources\
echo.
echo Then re-download the pack from repository.
echo.
set /p confirm="Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
    echo Canceled.
    pause
    exit /b
)

powershell -Command "irm https://raw.githubusercontent.com/isadora-6th/rybalka-3-retro/refs/heads/main/ResetPack.ps1 | iex"

pause
