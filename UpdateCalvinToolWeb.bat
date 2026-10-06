@echo off
setlocal EnableExtensions
chcp 65001 >nul

set "AppName=CalvinToolWeb"
set "ShareRoot=\\nas01\home\calvin.lin\share\CalvinToolReleased"
for %%I in ("%~dp0.") do set "DestRoot=%%~fI"
set "ArchivePath=%DestRoot%\CalvinToolWeb.zip"
set "FolderPath=%DestRoot%\CalvinToolWeb"
set "VersionPath=%DestRoot%\CalvinToolWeb\Version.txt"
set "ToolPath=%DestRoot%\CalvinToolWeb\CalvinToolWeb.exe"
set "LatestDir="
set "LatestFolder="
set "LatestVer="
set "InstalledVersion="

echo 檢查 %ShareRoot% ...
if not exist "%ShareRoot%\" (
    echo ERROR: 無法存取 %ShareRoot%
    goto Failed
)

echo 尋找最新的 %AppName% 套件...
for /f "delims=" %%D in ('dir /b /ad /o-n "%ShareRoot%\Z*" 2^>nul') do (
    if exist "%ShareRoot%\%%D\CalvinToolWeb.zip" (
        set "LatestDir=%ShareRoot%\%%D"
        set "LatestFolder=%%D"
        for /f "delims=_" %%V in ("%%D") do set "LatestVer=%%V"
        goto FoundLatest
    )
)

echo ERROR: 在 %ShareRoot% 找不到含 CalvinToolWeb.zip 的版本資料夾。
goto Failed

:FoundLatest
echo 最新資料夾：%LatestFolder%
echo 最新版本：%LatestVer%
echo 來源：%LatestDir%

if exist "%VersionPath%" set /p "InstalledVersion="<"%VersionPath%"
if defined InstalledVersion echo 本機版本：%InstalledVersion%

if /i "%InstalledVersion%"=="%LatestVer%" if exist "%ToolPath%" (
    call :CopyHelp
    echo 已是最新版本，略過更新。
    goto Done
)

tasklist /FI "IMAGENAME eq CalvinToolWeb.exe" | find /I "CalvinToolWeb.exe" >nul
if not errorlevel 1 (
    echo 正在結束執行中的 CalvinToolWeb.exe ...
    taskkill /IM CalvinToolWeb.exe /F >nul
    timeout /t 2 /nobreak >nul
)

echo 正在複製 %LatestFolder% （版本 %LatestVer%）...
copy /Y "%LatestDir%\CalvinToolWeb.zip" "%ArchivePath%" >nul
if errorlevel 1 goto CopyFailed
if exist "%LatestDir%\CalvinToolWeb.bat" (
    copy /Y "%LatestDir%\CalvinToolWeb.bat" "%DestRoot%\CalvinToolWeb.bat" >nul
    if errorlevel 1 goto CopyFailed
)

if exist "%FolderPath%" (
    echo 正在移除舊的 %FolderPath% ...
    rmdir /s /q "%FolderPath%"
    if exist "%FolderPath%" goto RemoveFailed
)

echo 正在解壓縮 %ArchivePath% ...
tar -xf "%ArchivePath%" -C "%DestRoot%"
if errorlevel 1 goto ExtractFailed
if not exist "%VersionPath%" goto InvalidPackage
if not exist "%ToolPath%" goto InvalidPackage

set "InstalledVersion="
set /p "InstalledVersion="<"%VersionPath%"
if /i not "%InstalledVersion%"=="%LatestVer%" goto InvalidPackage

call :CopyHelp
echo 更新完成：%InstalledVersion%

:Done
exit /b 0

:CopyHelp
if exist "%LatestDir%\使用說明.html" (
    echo 正在複製 使用說明.html ...
    copy /Y "%LatestDir%\使用說明.html" "%DestRoot%\使用說明.html" >nul
    if errorlevel 1 goto CopyFailed
)
goto :eof

:CopyFailed
echo ERROR: 無法從 NAS 複製檔案。
goto Failed

:RemoveFailed
echo ERROR: 無法刪除 %FolderPath%。請確認程式已關閉後再試。
goto Failed

:ExtractFailed
echo ERROR: 無法解壓縮 %ArchivePath%。
goto Failed

:InvalidPackage
echo ERROR: 解壓縮後的套件缺少檔案，或 Version.txt 與資料夾版號 %LatestVer% 不符。
goto Failed

:Failed
pause
exit /b 1
