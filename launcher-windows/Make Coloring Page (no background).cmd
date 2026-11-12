@echo off
rem Just the characters, no scenery.
rem Drag pictures onto this file, or double-click it to convert everything in the "input" folder.
call "%~dp0linecrafty.cmd" --open --style nobg %*
pause
