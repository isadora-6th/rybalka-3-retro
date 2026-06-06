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
echo.
echo Then re-download the pack from repository.
echo.
set /p confirm="Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
    echo Canceled.
    pause
    exit /b
)

echo.
echo --- Deleting texturepacks ---
if exist "instances\1.4.7\.minecraft\texturepacks" (
    del /f /s /q "instances\1.4.7\.minecraft\texturepacks\*" >nul 2>&1
    for /d %%D in ("instances\1.4.7\.minecraft\texturepacks\*") do rmdir /s /q "%%D" >nul 2>&1
    echo   Done.
) else (
    echo   Folder not found, skipping.
)

echo --- Deleting mods ---
if exist "instances\1.4.7\.minecraft\mods" (
    del /f /s /q "instances\1.4.7\.minecraft\mods\*" >nul 2>&1
    for /d %%D in ("instances\1.4.7\.minecraft\mods\*") do rmdir /s /q "%%D" >nul 2>&1
    echo   Done.
) else (
    echo   Folder not found, skipping.
)

echo --- Deleting coremods ---
if exist "instances\1.4.7\.minecraft\coremods" (
    del /f /s /q "instances\1.4.7\.minecraft\coremods\*" >nul 2>&1
    for /d %%D in ("instances\1.4.7\.minecraft\coremods\*") do rmdir /s /q "%%D" >nul 2>&1
    echo   Done.
) else (
    echo   Folder not found, skipping.
)

echo --- Deleting config ---
if exist "instances\1.4.7\.minecraft\config" (
    del /f /s /q "instances\1.4.7\.minecraft\config\*" >nul 2>&1
    for /d %%D in ("instances\1.4.7\.minecraft\config\*") do rmdir /s /q "%%D" >nul 2>&1
    echo   Done.
) else (
    echo   Folder not found, skipping.
)

echo.
echo ============================================
echo   Cleanup complete!
echo   Now downloading fresh pack files...
echo ============================================
echo.

call update.bat

echo.
echo ============================================
echo   Reset complete!
echo ============================================
pause
