@echo off
echo Setting up Toha theme...
echo.

REM Set environment paths
set "PATH=%~dp0go\bin;%~dp0nodejs;%~dp0hugo-new;%PATH%"
set "GOPATH=%~dp0gopath"
set "GOMODCACHE=%~dp0gopath\pkg\mod"

REM Change to site directory
cd /d "%~dp0site"

echo Initializing Hugo modules...
hugo mod init github.com/portfolio/site
if errorlevel 1 goto error

echo.
echo Downloading Toha theme...
hugo mod get -u
if errorlevel 1 goto error

echo.
echo Running hugo mod tidy...
hugo mod tidy
if errorlevel 1 goto error

echo.
echo Preparing npm packages...
hugo mod npm pack
if errorlevel 1 goto error

echo.
echo Installing npm dependencies...
call npm install
if errorlevel 1 goto error

echo.
echo ========================================
echo Setup complete! Run run-dev.bat to start
echo ========================================
pause
exit /b 0

:error
echo.
echo ERROR: Setup failed!
pause
exit /b 1
