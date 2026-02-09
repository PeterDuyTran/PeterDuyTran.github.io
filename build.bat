@echo off
echo Building Toha Portfolio for Production...
echo.

REM Set environment paths
set "PATH=%~dp0go\bin;%~dp0nodejs;%~dp0hugo-new;%PATH%"
set "GOPATH=%~dp0gopath"
set "GOMODCACHE=%~dp0gopath\pkg\mod"

cd /d "%~dp0site"

"%~dp0hugo-new\hugo.exe" --gc --minify

echo.
echo Build complete! Output is in: %~dp0site\public\
pause
