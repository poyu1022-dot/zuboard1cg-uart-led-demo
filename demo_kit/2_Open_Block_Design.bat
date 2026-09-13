@echo off
REM Edit this if Vivado is installed somewhere else:
set VIVADO_BIN=C:\AMDDesignTools\2026.1\Vivado\bin

echo Opening Vivado Block Design (system.bd)...
echo (Requires the project to exist under ..\build - run hardware\01_create_project.tcl first.)
"%VIVADO_BIN%\vivado.bat" -mode batch -notrace -source "%~dp0open_block_design.tcl"
