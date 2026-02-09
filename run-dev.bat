@echo off
echo Starting Toha Portfolio Development Server...
echo.

REM Set environment paths
set "PATH=%~dp0go\bin;%~dp0nodejs;%~dp0hugo-new;%PATH%"
set "GOPATH=%~dp0gopath"
set "GOMODCACHE=%~dp0gopath\pkg\mod"

cd /d "%~dp0site"

echo Site will be available at: http://localhost:1313/
echo Press Ctrl+C to stop
echo.

"%~dp0hugo-new\hugo.exe" server -D --navigateToChanged
