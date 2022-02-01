@echo off
setlocal EnableDelayedExpansion
setlocal ENABLEEXTENSIONS

for %%i in ("7z.dll" "7z.exe" "curl.exe" "curl-ca-bundle.crt" "diff.exe" "libiconv2.dll" "libintl3.dll" "regex2.dll" "sed.exe" "WinSCP.com" "WinSCP.exe") do if not exist "%%i" echo %%i missing & goto :EOF

SET M=%1
IF NOT DEFINED M ( echo. & echo Parameter require to determine action & echo. & goto :help ) 
if %M%==1 ( goto new ) else if %M%==2 ( goto update ) else ( echo. & echo INVAID PARAMETER, Try again. & echo. & goto :help )

:help
echo.
echo Usage:
echo sitewallconfig4.bat 1 ^<-- To set new configuration
echo sitewallconfig4.bat 2 ^<-- To update the configuration
echo.
goto :EOF

:new
del output.txt > nul 2> nul
del watch.txt > nul 2> nul
del sites.txt > nul 2> nul
del config.txt > nul 2> nul
del cid.txt > nul 2> nul
del update.txt > nul 2> nul
del temp*.txt > nul 2> nul
rmdir /s /q baseline > nul 2> nul
rmdir /s /q site > nul 2> nul
rmdir /s /q data > nul 2> nul
cls
set /p id="Enter SiteWALL Customer ID: "
echo %id%>cid.txt
curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmP.php?param=%id% > temp.txt || ( echo. & echo Unable to connect to SiteWALL & goto :EOF )
sed "s/<[^>]*>/\n/g" "temp.txt" > "config.txt" & del temp.txt > nul 2> nul
find /c /i "Invalid Parameter" config.txt >nul
if %errorlevel% equ 1 (
   ::file did not contains "invalid parameter"
    goto noinvaidparameter
    ) else (
       ::file contains "invalid parameter"
        echo.
        echo INVALID PARAMETER, please try again.
        echo.
        goto :EOF
        )

:noinvaidparameter
for %%R in (config.txt) do if %%~zR equ 0 ( echo. & echo NO DATA FOUND. contact ^<soc@pengentra.com^> & echo. & del config.txt 2> nul & goto :EOF )
echo.
echo This may take a while.....
for /f "tokens=1" %%a in (config.txt) do (
mkdir baseline\%%a > nul 2> nul
mkdir site\%%a > nul 2> nul
mkdir data > nul 2> nul
)
for /f "tokens=1,3 delims= " %%a in (config.txt) do (
rem echo %%a %%b
if exist %%b (
   echo.
   xcopy "%%b\*.php"  "baseline\%%a" /sy
   xcopy "%%b\*.aspx" "baseline\%%a" /sy
) else (
   echo.
   echo.
   echo %%b - This Folder not exist, Please enter correct full path. Run 'sitewallconfig.exe' again.
   echo.
   echo.
)
)
7z.exe a -tzip config-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip baseline > nul
(winscp.com /command ^
   "option confirm off" ^
   "option echo off"^
   "open sftp://projectpagentra:PpAa@890@cp.pagentra.com -hostkey=""string value""" ^
   "option batch continue" ^
   "mkdir /home/projectpagentra/sandesh/%id%" ^
   "option batch off" ^
   "cd /home/projectpagentra/sandesh/%id%" ^
   "put config-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip" ^
   "put config.txt" ^
   "exit") > latesttransfer1.log && (
del config-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip
rem del config.txt
echo.
echo Congratulations. Your configuration is successful.
echo Next^, Set following files to run in windows task scheduler -
echo 1^) sitewallconfig4.bat with argument 2
echo 2^) sitewallscript4.bat
echo 3^) filetest4.bat
echo.
echo To add more websites or any further queries please contact to ^<soc@pagentra.com^>.
echo.
) || ( echo. & echo Unable to send files to SiteWALL )
goto :EOF


:update
if not exist baseline (
   echo.
   echo NO CONFIGURATION FOUND.
   echo command to set new configuration --^> sitewallconfig4.bat 1
   echo.
   goto :EOF
)
del update* 2> nul
set /P id=< cid.txt
curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmP.php?param=%id% > temp1.txt || ( echo. & echo Unable to connect to SiteWALL & goto :EOF )
sed "s/<[^>]*>/\n/g" "temp1.txt" > "temp2.txt" & del temp1.txt

for /f "tokens=1,2,3,4" %%a in (temp2.txt) do (
if %%d==1 (
   echo.
   echo %%b %%c ^<-- New configuraton found. Updating baseline...
   echo.
   echo %%a %%b %%c %%d >> update.txt
)
)
del sed*. > nul 2> nul

if exist update.txt (
echo.
echo This may take a while.....
for /f "tokens=1,3" %%a in (update.txt) do (
if exist %%b (
   rmdir /s /q baseline\%%a 2> nul
   rmdir /s /q site\%%a 2> nul
   mkdir baseline\%%a 2> nul
   mkdir site\%%a 2> nul
   mkdir update 2> nul
   echo.
   xcopy "%%b\*.php" "baseline\%%a" /sy
   xcopy "%%b\*.aspx" "baseline\%%a" /sy
   xcopy "%%b\*.php" "update\" /sy > nul 2> nul
   xcopy "%%b\*.aspx" "update\" /sy > nul 2> nul
) else (
   echo.
   echo.
   echo %%b - Directory does not exist, please verify path on sitewall portal.
   echo.
   echo.
)
)
) else (
echo No Update & goto :EOF
)
7z.exe a -tzip update-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip update > nul
(winscp.com /command ^
   "option confirm off" ^
   "option echo off"^
   "open sftp://projectpagentra:PpAa@890@cp.pagentra.com -hostkey=""string value""" ^
   "option batch continue" ^
   "mkdir /home/projectpagentra/sandesh/%id%" ^
   "option batch off" ^
   "cd /home/projectpagentra/sandesh/%id%" ^
   "put update-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip" ^
   "put update.txt" ^
   "exit") > latesttransfer1.log && (
del config.txt & rename "temp2.txt" "config.txt"
del update-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip 2> nul
del update.txt 2> nul
del sites.txt 2> nul
del temp3.txt 2> nul
rmdir /s /q update 2> nul
) || ( echo. & echo Unable to send files to SiteWALL )

endlocal
goto :EOF
Rem here is the final control

