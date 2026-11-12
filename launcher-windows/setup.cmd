@echo off
setlocal
rem Runs setup.py. Finds a Python to run it with: the py launcher, a python.exe on PATH, or (so that
rem nothing extra has to be installed) the Python that comes inside Comfy Desktop.
set "LC_ROOT=%~dp0.."

rem Files from a downloaded zip are "blocked" by Windows; unblock ours so they run without prompts.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath $env:LC_ROOT -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1

set "PY="
for /f "delims=" %%P in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do if not defined PY set "PY=%%P"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul ^| findstr /v /i "WindowsApps"') do if not defined PY set "PY=%%P"
if not defined PY for /f "delims=" %%P in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$f = Join-Path $env:APPDATA 'Comfy Desktop\installations.json'; if (Test-Path $f) { foreach ($i in (Get-Content $f -Raw | ConvertFrom-Json)) { if ($i.installPath) { foreach ($r in 'ComfyUI\.venv\Scripts\python.exe', '.venv\Scripts\python.exe') { $p = Join-Path $i.installPath $r; if (Test-Path $p) { $p; exit } } } } }" 2^>nul') do if not defined PY set "PY=%%P"

if not defined PY (
  echo.
  echo  Couldn't find Python or Comfy Desktop.
  echo  Install Comfy Desktop from https://www.comfy.org/download and open it once, or install
  echo  Python from https://www.python.org/downloads/ , then run this again.
  echo.
  pause
  exit /b 1
)

rem setup.py waits for Enter at the end itself, so the window stays open.
"%PY%" "%LC_ROOT%\setup.py" %*
