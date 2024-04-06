@set iasver=1.2
@setlocal DisableDelayedExpansion
@echo off



::============================================================================
::
::   IDM 啟動腳本 (IAS)
::
::   Homepages: https://github.com/WindowsAddict/IDM-Activation-Script
::              https://massgrave.dev/idm-activation-script
::
::       電子郵件：windowsaddict@protonmail.com
::
::============================================================================



::  若要激活，請使用“/act”參數運行腳本或將以下行中的 0 變更為 1
set _activate=0

::  若要凍結 30 天試用期，請使用「/frz」參數執行腳本或將以下行中的 0 變更為 1
set _freeze=0

::  若要重設啟動和試用，請使用“/res”參數執行腳本或將以下行中的 0 變更為 1
set _reset=0

::  如果以上行中的值發生變更或使用參數，則腳本將以無人值守模式執行

::========================================================================================================================================

::  設定Path變量，如果系統中配置錯誤，它會有所幫助

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

:: 如果腳本是由 x64 位元 Windows 上的 x86 進程啟動，則使用 x64 進程重新啟動該腳本
:: 或使用 ARM64 進程（如果它是由 ARM64 Windows 上的 x86/ARM32 進程啟動）

set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="r1" set r1=1
if /i "%%#"=="r2" set r2=1
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
exit /b
)

:: 如果腳本是由 ARM64 Windows 上的 x64 進程啟動的，則使用 ARM32 進程重新啟動該腳本

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::========================================================================================================================================

set "blank="
set "mas=ht%blank%tps%blank%://mass%blank%grave.dev/"

::  檢查 Null 服務是否正常運作，這對於批次腳本很重要

sc query Null | find /i "RUNNING"
if %errorlevel% NEQ 0 (
echo:
echo 空服務未運行，腳本可能崩潰...
echo:
echo:
echo 幫助 - %mas%idm-activation-script.html#Troubleshoot
echo:
echo:
ping 127.0.0.1 -n 10
)
cls

::  檢查 LF 行結尾

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
echo:
echo 錯誤：腳本存在 LF 行結束問題或腳本結尾缺少空白行.
echo:
ping 127.0.0.1 -n 6 >nul
popd
exit /b
)
popd

::========================================================================================================================================

cls
color 07
title  IDM 啟動腳本 %iasver%

set _args=
set _elev=
set _unattended=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="-el"  set _elev=1
if /i "%%A"=="/res" set _reset=1
if /i "%%A"=="/frz" set _freeze=1
if /i "%%A"=="/act" set _activate=1
)
)

for %%A in (%_activate% %_freeze% %_reset%) do (if "%%A"=="1" set _unattended=1)

::========================================================================================================================================

set "nul1=1>nul"
set "nul2=2>nul"
set "nul6=2^>nul"
set "nul=>nul 2>&1"

set psc=powershell.exe
set winbuild=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 %nul2% | find /i "0x0" %nul1% && (set _NCS=0)

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
set     "Red="41;97m""
set    "Gray="100;97m""
set   "Green="42;97m""
set    "Blue="44;97m""
set  "_White="40;37m""
set  "_Green="40;92m""
set "_Yellow="40;93m""
) else (
set     "Red="Red" "white""
set    "Gray="Darkgray" "white""
set   "Green="DarkGreen" "white""
set    "Blue="Blue" "white""
set  "_White="Black" "Gray""
set  "_Green="Black" "Green""
set "_Yellow="Black" "Yellow""
)

set "nceline=echo: &echo ==== ERROR ==== &echo:"
set "eline=echo: &call :_color %Red% "==== ERROR ====" &echo:"
set "line=___________________________________________________________________________________________________"
set "_buf={$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=34;$B.Height=300;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"

::========================================================================================================================================

if %winbuild% LSS 7600 (
%nceline%
echo 偵測到不支援的作業系統版本 [%winbuild%].
echo 僅 Windows 7/8/8.1/10/11 及其等效伺服器支援項目.
goto done2
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
%nceline%
echo 系統中找不到powershell.exe.
goto done2
)

::========================================================================================================================================

::  修復路徑名中的特殊字元限制

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%
set _PSarg=%_PSarg:'=''%

set "_appdata=%appdata%"
set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" %nul1% && (
if /i not "!_work!"=="!_ttemp!" (
%eline%
echo 腳本從臨時資料夾啟動,
echo 您很可能直接從存檔文件運行腳本.
echo:
echo 提取存檔檔案並從提取的資料夾中啟動腳本.
goto done2
)
)

::========================================================================================================================================

::  檢查 PowerShell

REM :PowerShellTest: $ExecutionContext.SessionState.LanguageMode :PowerShellTest:

%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':PowerShellTest:\s*';iex ($f[1])" | find /i "FullLanguage" %nul1% || (
%eline%
%psc% $ExecutionContext.SessionState.LanguageMode
echo:
echo PowerShell 無法運作。正在中止...
echo 如果您對 Powershell 應用了限制，請撤銷這些更改.
echo:
echo 檢查此頁面尋求協助。 %mas%idm-activation-script.html#疑難排解
goto done2
)

::========================================================================================================================================

::  將腳本提升為管理員並傳遞參數並防止循環

%nul1% fltmc || (
if not defined _elev %psc% "start cmd.exe -arg '/c \"!_PSarg!\"' -verb runas" && exit /b
%eline%
echo 該腳本需要管理員權限.
echo 為此，請右鍵單擊此腳本並選擇“以管理員身份執行”'.
goto done2
)

::========================================================================================================================================

::  停用 QuickEdit 並從 conhost.exe 啟動以避免終端應用程式

set quedit=
set terminal=

if %_unattended%==1 (
set quedit=1
set terminal=1
)

for %%# in (%_args%) do (if /i "%%#"=="-qedit" set quedit=1)

if %winbuild% LSS 10586 (
reg query HKCU\Console /v QuickEdit %nul2% | find /i "0x0" %nul1% && set quedit=1
)

if %winbuild% GEQ 17763 (
set "launchcmd=start conhost.exe %psc%"
) else (
set "launchcmd=%psc%"
)

set "d1=$t=[AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1).DefineDynamicModule(2, $False).DefineType(0);"
set "d2=$t.DefinePInvokeMethod('GetStdHandle', 'kernel32.dll', 22, 1, [IntPtr], @([Int32]), 1, 3).SetImplementationFlags(128);"
set "d3=$t.DefinePInvokeMethod('SetConsoleMode', 'kernel32.dll', 22, 1, [Boolean], @([IntPtr], [Int32]), 1, 3).SetImplementationFlags(128);"
set "d4=$k=$t.CreateType(); $b=$k::SetConsoleMode($k::GetStdHandle(-10), 0x0080);"

if defined quedit goto :skipQE
%launchcmd% "%d1% %d2% %d3% %d4% & cmd.exe '/c' '!_PSarg! -qedit'" &exit /b
:skipQE

::========================================================================================================================================

::  檢查更新

set -=
set old=

for /f "delims=[] tokens=2" %%# in ('ping -4 -n 1 iasupdatecheck.mass%-%grave.dev') do (
if not [%%#]==[] (echo "%%#" | find "127.69" %nul1% && (echo "%%#" | find "127.69.%iasver%" %nul1% || set old=1))
)

if defined old (
echo ________________________________________________
%eline%
echo        您正在運行過時的 IAS 版本 %iasver%
echo ________________________________________________
echo:
if not %_unattended%==1 (
echo [1] 取得最新的 IAS
echo [0] 無論如何繼續
echo:
call :_color %_Green% "在鍵盤中輸入選單選項 [1,0] :"
choice /C:10 /N
if !errorlevel!==2 rem
if !errorlevel!==1 (start https://github.com/WindowsAddict/IDM-Activation-Script & start %mas%/idm-activation-script & exit /b)
)
)

::========================================================================================================================================

cls
title  IDM 啟動腳本 %iasver%

echo:
echo 正在初始化...

::  Check WMI

%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName" %nul2% | find /i "computersystem" %nul1% || (
%eline%
%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName"
echo:
echo WMI 不工作。正在中止...
echo:
echo 檢查此頁面尋求協助。 %mas%idm-activation-script.html#疑難排解
goto done2
)

::  檢查使用者帳戶SID

set _sid=
for /f "delims=" %%a in ('%psc% "([System.Security.Principal.NTAccount](Get-WmiObject -Class Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value" %nul6%') do (set _sid=%%a)
 
reg query HKU\%_sid%\Software %nul% || (
for /f "delims=" %%a in ('%psc% "$explorerProc = Get-Process -Name explorer | Where-Object {$_.SessionId -eq (Get-Process -Id $pid).SessionId} | Select-Object -First 1; $sid = (gwmi -Query ('Select * From Win32_Process Where ProcessID=' + $explorerProc.Id)).GetOwnerSid().Sid; $sid" %nul6%') do (set _sid=%%a)
)

reg query HKU\%_sid%\Software %nul% || (
%eline%
echo:
echo [%_sid%]
echo 未找到使用者帳戶 SID。正在中止...
echo:
echo 檢查此頁面尋求協助。 %mas%idm-activation-script.html#疑難排解
goto done2
)

::========================================================================================================================================

::  檢查目前使用者 SID 是否與 HKCU 條目同步

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

set HKCUsync=$null
%nul% reg add HKCU\IAS_TEST
%nul% reg query HKU\%_sid%\IAS_TEST && (
set HKCUsync=1
)

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

::  下面的程式碼也適用於 ARM64 Windows 10（包括 x64 位元模擬）

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b
if /i not "%arch%"=="x86" set arch=x64

if "%arch%"=="x86" (
set "CLSID=HKCU\Software\Classes\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\CLSID"
set "HKLM=HKLM\Software\Internet Download Manager"
) else (
set "CLSID=HKCU\Software\Classes\Wow6432Node\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\Wow6432Node\CLSID"
set "HKLM=HKLM\SOFTWARE\Wow6432Node\Internet Download Manager"
)

for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v ExePath %nul6%') do call set "IDMan=%%b"

if not exist "%IDMan%" (
if %arch%==x64 set "IDMan=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
if %arch%==x86 set "IDMan=%ProgramFiles%\Internet Download Manager\IDMan.exe"
)

if not exist %SystemRoot%\Temp md %SystemRoot%\Temp
set "idmcheck=tasklist /fi "imagename eq idman.exe" | findstr /i "idman.exe" %nul1%"

::  檢查 CLSID 註冊表訪問

%nul% reg add %CLSID2%\IAS_TEST
%nul% reg query %CLSID2%\IAS_TEST || (
%eline%
echo 寫入失敗 %CLSID2%
echo:
echo 檢查此頁面尋求協助。 %mas%idm-activation-script.html#疑難排解
goto done2
)

%nul% reg delete %CLSID2%\IAS_TEST /f

::========================================================================================================================================

if %_reset%==1 goto :_reset
if %_activate%==1 (set frz=0&goto :_activate)
if %_freeze%==1 (set frz=1&goto :_activate)

:MainMenu

cls
title  IDM 啟動腳本 %iasver%
if not defined terminal mode 75, 28

echo:
echo:
echo:
echo:
echo:
echo:
echo:            ___________________________________________________ 
echo:                                                               
echo:               [1] Freeze Trial
echo:               [2] 啟用 ^(Not working^)
echo:               [3] 重置激活/試用
echo:               _____________________________________________   
echo:                                                               
echo:               [4] 下載IDM
echo:               [5] 幫助
echo:               [0] Exit
echo:            ___________________________________________________
echo:         
call :_color2 %_White% "             " %_Green% 「在鍵盤中輸入選單選項 [1,2,3,4,5,0]"
choice /C:123450 /N
set _erl=%errorlevel%

if %_erl%==6 exit /b
if %_erl%==5 start https://github.com/WindowsAddict/IDM-Activation-Script & start https://massgrave.dev/idm-activation-script & goto MainMenu
if %_erl%==4 start https://www.internetdownloadmanager.com/download.html & goto MainMenu
if %_erl%==3 goto _reset
if %_erl%==2 (set frz=0&goto :_activate)
if %_erl%==1 (set frz=1&goto :_activate)
goto :MainMenu

::========================================================================================================================================

:_reset

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 35
) else (
if not defined terminal mode 113, 35
)
if not defined terminal %psc% "&%_buf%" %nul%

echo:
%idmcheck% && taskkill /f /im idman.exe

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo 建立 CLSID 登錄項目的備份 %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = $null; $deleteKey = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

call :add_key

echo:
echo %line%
echo:
call :_color %Green% "IDM重置程序已完成."

goto done

:delete_queue

echo:
echo 刪除 IDM 註冊表項...
echo:

for %%# in (
""HKCU\Software\DownloadManager" "/v" "FName""
""HKCU\Software\DownloadManager" "/v" "LName""
""HKCU\Software\DownloadManager" "/v" "Email""
""HKCU\Software\DownloadManager" "/v" "Serial""
""HKCU\Software\DownloadManager" "/v" "scansk""
""HKCU\Software\DownloadManager" "/v" "tvfrdt""
""HKCU\Software\DownloadManager" "/v" "radxcnt""
""HKCU\Software\DownloadManager" "/v" "LstCheck""
""HKCU\Software\DownloadManager" "/v" "ptrk_scdt""
""HKCU\Software\DownloadManager" "/v" "LastCheckQU""
"%HKLM%"
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

if not %HKCUsync%==1 for %%# in (
""HKU\%_sid%\Software\DownloadManager" "/v" "FName""
""HKU\%_sid%\Software\DownloadManager" "/v" "LName""
""HKU\%_sid%\Software\DownloadManager" "/v" "Email""
""HKU\%_sid%\Software\DownloadManager" "/v" "Serial""
""HKU\%_sid%\Software\DownloadManager" "/v" "scansk""
""HKU\%_sid%\Software\DownloadManager" "/v" "tvfrdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "radxcnt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LstCheck""
""HKU\%_sid%\Software\DownloadManager" "/v" "ptrk_scdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LastCheckQU""
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

exit /b

:del

reg delete %reg% /f %nul%

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo Deleted - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "Failed - !reg!"
)

exit /b

::========================================================================================================================================

:_activate

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 35
) else (
if not defined terminal mode 113, 35
)
if not defined terminal %psc% "&%_buf%" %nul%

if %frz%==0 if %_unattended%==0 (
echo:
echo %line%
echo:
echo      某些用戶無法激活，IDM 可能會顯示虛假的串行導航螢幕.
echo:
call :_color2 %_White% "     " %_Green% "Its recommended to use Freeze Trial option instead."
echo %line%
echo:
choice /C:19 /N /M ">    [1] 返回 [9] 激活 : "
if !errorlevel!==1 goto :MainMenu
cls
)

echo:
if not exist "%IDMan%" (
call :_color %Red% "IDM [Internet Download Manager] is not Installed."
echo 您可以從以下位置下載：  https://www.internetdownloadmanager.com/download.html
goto done
)

:: 使用 internetdownloadmanager.com ping 和連接埠 80 測試進行網路檢查

set _int=
for /f "delims=[] tokens=2" %%# in ('ping -n 1 internetdownloadmanager.com') do (if not [%%#]==[] set _int=1)

if not defined _int (
%psc% "$t = New-Object Net.Sockets.TcpClient;try{$t.Connect("""internetdownloadmanager.com""", 80)}catch{};$t.Connected" | findstr /i "true" %nul1% || (
call :_color %Red% "Unable to connect internetdownloadmanager.com, aborting..."
goto done
)
call :_color %Gray% "Ping command failed for internetdownloadmanager.com"
echo:
)

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "regwinos=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set "regarch=%%b"
for /f "tokens=6-7 delims=[]. " %%i in ('ver') do if "%%j"=="" (set fullbuild=%%i) else (set fullbuild=%%i.%%j)
for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v idmvers %nul6%') do set "IDMver=%%b"

echo 檢查訊息 - [%regwinos% ^| %fullbuild% ^| %regarch% ^| IDM: %IDMver%]

%idmcheck% && (echo: & taskkill /f /im idman.exe)

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo 建立 CLSID 登錄項目的備份  %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
call :add_key

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $toggle = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

if %frz%==0 call :register_IDM

call :download_files
if not defined _fileexist (
%eline%
echo 錯誤：無法使用 IDM 下載文件.
echo:
echo 幫助: %mas%idm-activation-script.html#疑難排解
goto :done
)

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

echo:
echo %line%
echo:
if %frz%==0 (
call :_color %Green% "IDM 啟動程序已完成."
echo:
call :_color %Gray% "如果出現假串列螢幕，請改用「凍結試用」選項."
) else (
call :_color %Green% "IDM 30天試用期成功凍結終身."
echo:
call :_color %Gray% "如果 IDM 顯示註冊彈出窗口，請重新安裝 IDM."
)

::========================================================================================================================================

:done

echo %line%
echo:
echo:
if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
call :_color %_Yellow% "按0鍵返回..."
choice /c 0 /n
) else (
call :_color %_Yellow% "按任意鍵返回..."
pause %nul1%
)
goto MainMenu

:done2

if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
echo 按0鍵退出...
choice /c 0 /n
) else (
echo 按任何一個鍵退出...
pause %nul1%
)
exit /b

::========================================================================================================================================

:_rcont

reg add %reg% %nul%
call :add
exit /b

:register_IDM

echo:
echo 申請註冊詳細信息...
echo:

set /a fname = %random% %% 9999 + 1000
set /a lname = %random% %% 9999 + 1000
set email=%fname%.%lname%@tonec.com

for /f "delims=" %%a in ('%psc% "$key = -join ((Get-Random -Count  20 -InputObject ([char[]]('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'))));$key = ($key.Substring(0,  5) + '-' + $key.Substring(5,  5) + '-' + $key.Substring(10,  5) + '-' + $key.Substring(15,  5) + $key.Substring(20));Write-Output $key" %nul6%') do (set key=%%a)

set "reg=HKCU\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont

if not %HKCUsync%==1 (
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont
)
exit /b

:download_files

echo:
echo 觸發一些下載以建立某些註冊表項，請稍候...
echo:

set "file=%SystemRoot%\Temp\temp.png"
set _fileexist=

set link=https://www.internetdownloadmanager.com/images/idm_box_min.png
call :download
set link=https://www.internetdownloadmanager.com/register/IDMlib/images/idman_logos.png
call :download
set link=https://www.internetdownloadmanager.com/pictures/idm_about.png
call :download

echo:
timeout /t 3 %nul1%
%idmcheck% && taskkill /f /im idman.exe
if exist "%file%" del /f /q "%file%"
exit /b

:download

set /a attempt=0
if exist "%file%" del /f /q "%file%"
start "" /B "%IDMan%" /n /d "%link%" /p "%SystemRoot%\Temp" /f temp.png

:check_file

timeout /t 1 %nul1%
set /a attempt+=1
if exist "%file%" set _fileexist=1&exit /b
if %attempt% GEQ 20 exit /b
goto :Check_file

::========================================================================================================================================

:add_key

echo:
echo 新增註冊表項...
echo:

set "reg="%HKLM%" /v "AdvIntDriverEnabled2""

reg add %reg% /t REG_DWORD /d "1" /f %nul%

:add

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo Added - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "Failed - !reg!"
)
exit /b

::========================================================================================================================================

:regscan:
$finalValues = @()

$arch = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
if ($arch -eq "x86") {
  $regPaths = @("HKCU:\Software\Classes\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\CLSID")
} else {
  $regPaths = @("HKCU:\Software\Classes\WOW6432Node\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\Wow6432Node\CLSID")
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
	
	Write-Host
	Write-Host "Searching IDM CLSID Registry Keys in $regPath"
	Write-Host
	
    $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue -ErrorVariable lockedKeys | Where-Object { $_.PSChildName -match '^\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}$' }

    foreach ($lockedKey in $lockedKeys) {
        $leafValue = Split-Path -Path $lockedKey.TargetObject -Leaf
        $finalValues += $leafValue
        Write-Output "$leafValue - Found Locked Key"
    }

    if ($subKeys -eq $null) {
	continue
	}
	
	$subKeysToExclude = "LocalServer32", "InProcServer32", "InProcHandler32"

    $filteredKeys = $subKeys | Where-Object { !($_.GetSubKeyNames() | Where-Object { $subKeysToExclude -contains $_ }) }

    foreach ($key in $filteredKeys) {
        $fullPath = $key.PSPath
        $keyValues = Get-ItemProperty -Path $fullPath -ErrorAction SilentlyContinue
        $defaultValue = $keyValues.PSObject.Properties | Where-Object { $_.Name -eq '(default)' } | Select-Object -ExpandProperty Value

        if (($defaultValue -match "^\d+$") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - Found Digit In Default and No Subkeys"
            continue
        }
        if (($defaultValue -match "\+|=") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - Found + or = In Default and No Subkeys"
            continue
        }
        $versionValue = Get-ItemProperty -Path "$fullPath\Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)' -ErrorAction SilentlyContinue
        if (($versionValue -match "^\d+$") -and ($key.SubKeyCount -eq 1)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - Found Digit In \Version and No Other Subkeys"
            continue
        }
        $keyValues.PSObject.Properties | ForEach-Object {
            if ($_.Name -match "MData|Model|scansk|Therad") {
                $finalValues += $($key.PSChildName)
                Write-Output "$($key.PSChildName) - Found MData Model scansk Therad"
                continue
            }
        }
        if (($key.ValueCount -eq 0) -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - Found Empty Key"
            continue
        }
    }
}

$finalValues = @($finalValues | Select-Object -Unique)

if ($finalValues -ne $null) {
    Write-Host
    if ($lockKey -ne $null) {
        Write-Host "Locking IDM CLSID Registry Keys..."
    }
    if ($deleteKey -ne $null) {
        Write-Host "Deleting IDM CLSID Registry Keys..."
    }
    Write-Host
} else {
    Write-Host "IDM CLSID Registry Keys are not found."
	Exit
}

if (($finalValues.Count -gt 20) -and ($toggle -ne $null)) {
	$lockKey = $null
	$deleteKey = 1
    Write-Host "The IDM keys count is more than 20. Deleting them now instead of locking..."
	Write-Host
}

function Take-Permissions {
    param($rootKey, $regKey)
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule(2, $False)
    $TypeBuilder = $ModuleBuilder.DefineType(0)

    $TypeBuilder.DefinePInvokeMethod('RtlAdjustPrivilege', 'ntdll.dll', 'Public, Static', 1, [int], @([int], [bool], [bool], [bool].MakeByRefType()), 1, 3) | Out-Null
    9,17,18 | ForEach-Object { $TypeBuilder.CreateType()::RtlAdjustPrivilege($_, $true, $false, [ref]$false) | Out-Null }

    $SID = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $IDN = ($SID.Translate([System.Security.Principal.NTAccount])).Value
    $Admin = New-Object System.Security.Principal.NTAccount($IDN)

    $everyone = New-Object System.Security.Principal.SecurityIdentifier('S-1-1-0')
    $none = New-Object System.Security.Principal.SecurityIdentifier('S-1-0-0')

    $key = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($regkey, 'ReadWriteSubTree', 'TakeOwnership')

    $acl = New-Object System.Security.AccessControl.RegistrySecurity
    $acl.SetOwner($Admin)
    $key.SetAccessControl($acl)

    $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'ContainerInherit', 'None', 'Allow')
    $acl.ResetAccessRule($rule)
    $key.SetAccessControl($acl)

    if ($lockKey -ne $null) {
        $acl = New-Object System.Security.AccessControl.RegistrySecurity
        $acl.SetOwner($none)
        $key.SetAccessControl($acl)

        $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'Deny')
        $acl.ResetAccessRule($rule)
        $key.SetAccessControl($acl)
    }
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
    foreach ($finalValue in $finalValues) {
        $fullPath = Join-Path -Path $regPath -ChildPath $finalValue
        if ($fullPath -match 'HKCU:') {
            $rootKey = 'CurrentUser'
        } else {
            $rootKey = 'Users'
        }

        $position = $fullPath.IndexOf("\")
        $regKey = $fullPath.Substring($position + 1)

        if ($lockKey -ne $null) {
            if (-not (Test-Path -Path $fullPath -ErrorAction SilentlyContinue)) { New-Item -Path $fullPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Take-Permissions $rootKey $regKey
            try {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
            }
            catch {
                Write-Host "Locked - $fullPath"
            }
        }

        if ($deleteKey -ne $null) {
            if (Test-Path -Path $fullPath) {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $fullPath) {
                    Take-Permissions $rootKey $regKey
                    try {
                        Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                        Write-Host "Deleted - $fullPath"
                    }
                    catch {
                        Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
                    }
                }
                else {
                    Write-Host "Deleted - $fullPath"
                }
            }
        }
    }
}
:regscan:

::========================================================================================================================================

:_color

if %_NCS% EQU 1 (
echo %esc%[%~1%~2%esc%[0m
) else (
%psc% write-host -back '%1' -fore '%2' '%3'
)
exit /b

:_color2

if %_NCS% EQU 1 (
echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
%psc% write-host -back '%1' -fore '%2' '%3' -NoNewline; write-host -back '%4' -fore '%5' '%6'
)
exit /b

::========================================================================================================================================
:: 下面留空行
