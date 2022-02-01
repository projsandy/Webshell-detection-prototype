@echo off 
setlocal EnableDelayedExpansion
setlocal ENABLEEXTENSIONS

for %%i in ("7z.dll" "7z.exe" "curl.exe" "curl-ca-bundle.crt" "diff.exe" "libiconv2.dll" "libintl3.dll" "regex2.dll" "sed.exe" "WinSCP.com" "WinSCP.exe" "cid.txt" "config.txt") do if not exist "%%i" echo %%i missing & goto :EOF

if exist cid.txt (
set /p id=<cid.txt
) else (
    echo CUSTOMER ID NOT FOUND.
    goto :EOF
)

if exist config.txt (
for /f "tokens=1,3 delims= " %%a in (config.txt) do (
::echo %%a %%b
if exist %%b (
   xcopy "%%b\*.php"  "site\%%a\" /sy > nul 2> nul
   xcopy "%%b\*.aspx" "site\%%a\" /sy > nul 2> nul
) else (
    echo.
    echo %%b - Directory does not exist, Please validate path on sitewall portal. & goto :EOF
    echo.
)
)


diff -qrN site baseline > input.txt 2> nul
sed "s|\/|\\|g" input.txt > input1.txt & del input.txt

(for /f "tokens=2 delims= " %%a in (input1.txt) do echo %%a) > output.txt & del input1.txt

FOR %%R in (output.txt) DO IF %%~zR EQU 0 (del output.txt)

if exist output.txt (
    for /f  %%a in (output.txt) do (
        echo %%a >> file.txt
        xcopy "%%a" "data\" /sy > nul 2> nul
        CertUtil -hashfile %%a | findstr -v ash >> hash.txt
    )
    echo.
    echo Some files has been modified. Don't press any key, sending files to SiteWALL for analysis...
    echo.
    < hash.txt (
   for /F "delims=" %%a in (file.txt) do (
      set /P line2=
      set line2=!line2: =!
      echo !line2!  %%a)
    ) > buffer-%date:~-4,4%%date:~-7,2%%date:~-10,2%.txt
    del file.txt > nul
    del hash.txt > nul
    7z.exe a -tzip buffer-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip data > nul
    set /p id=<cid.txt
    ( winscp.com /command ^
   "option confirm off" ^
   "option echo off"^
   "open sftp://projectpagentra:PpAa@890@cp.pagentra.com -hostkey=""string value""" ^
   "option batch continue" ^
   "mkdir /home/projectpagentra/sandesh/!id!" ^
   "option batch off" ^
   "cd /home/projectpagentra/sandesh/!id!" ^
   "put buffer-%date:~-4,4%%date:~-7,2%%date:~-10,2%.zip" ^
   "put buffer-%date:~-4,4%%date:~-7,2%%date:~-10,2%.txt" ^
   "exit" ) > latesttransfer2.log && goto heartbeat2 || ( echo. & echo Unable to send files to SiteWALL & goto :EOF )
) else (
    echo.
    echo.
    curl https://portal.sitewall.net/heartbeat.php?param=%id% && ( echo. & echo All looks good. )
    echo.
    echo.
)
goto :EOF
) else (
    echo CONFIG DATA NOT FOUND.
    goto :EOF
)
rem Here is the end of the control


:heartbeat2
curl https://portal.sitewall.net/heartbeat.php?param=%id%  && (
rmdir /s /q baseline > nul 2> nul
rmdir /s /q data >nul 2> nul
ren site baseline
for /f "tokens=1 delims= " %%a in (config.txt) do (
   mkdir site\%%a
)
mkdir data
del output.txt > nul
del buffer-* 2> nul
)
goto :EOF

endlocal
