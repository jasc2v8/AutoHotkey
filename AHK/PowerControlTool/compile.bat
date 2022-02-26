@echo off
setlocal
set exe="C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
rem 0 = no, 1 = use MPRESS if present, 2 = use UPX if present
%exe% /in PowerControlTool.ahk /icon power_button.ico /compress 0
