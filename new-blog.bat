@echo off
if "%~1"=="" (
    echo Usage: new-blog.bat post-title-here
    echo Example: new-blog.bat my-new-article
    pause
    exit /b 1
)

set "PATH=%~dp0go\bin;%~dp0nodejs;%~dp0hugo-new;%PATH%"
set "GOPATH=%~dp0gopath"
set "GOMODCACHE=%~dp0gopath\pkg\mod"

cd /d "%~dp0site"
"%~dp0hugo-new\hugo.exe" new posts/%~1.md

echo.
echo Created: site\content\posts\%~1.md
echo Edit this file and remove "draft: true" when ready to publish
pause
