@echo off
REM Edit this if Vitis is installed somewhere else:
set VITIS_BIN=C:\AMDDesignTools\2026.1\Vitis\bin

echo ============================================
echo   ZUBoard 1CG - Programming via JTAG...
echo ============================================
"%VITIS_BIN%\xsdb.bat" "%~dp0..\scripts\program_and_run.tcl"
echo.
echo ============================================
echo   Done! Now double-click ZUBoard_Demo.html
echo   to see the live UART output in your browser.
echo ============================================
pause
