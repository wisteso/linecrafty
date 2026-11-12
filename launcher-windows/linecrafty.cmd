@echo off
setlocal
rem Runs linecrafty.py with ComfyUI's Python (recorded by setup), so no other Python is needed.
rem Command-line use: linecrafty.cmd photo.jpg --style all   (linecrafty.cmd --help for everything)
set "LC_ROOT=%~dp0.."
if not exist "%LC_ROOT%\python_path.txt" (
  echo Not set up yet: run launcher-windows\setup.cmd first.
  exit /b 1
)
set /p PY=<"%LC_ROOT%\python_path.txt"
"%PY%" -s "%LC_ROOT%\linecrafty.py" %*
