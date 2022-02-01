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

curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmhj.php?param=%id% > temp1.txt || ( echo. & echo Unable to connect to SiteWALL & goto :EOF )
sed "s/<[^>]*>/\n/g" "temp1.txt" > "temp2.txt" & del temp1.txt

for /f "tokens=1,2 delims= " %%a in (temp2.txt) do (
if exist %%b (
    CertUtil -hashfile %%b | findstr -v ash >> temphash.txt
) else (
    echo NOT-FOUND >> temphash.txt
)
)
< temphash.txt (
   for /f "tokens=1,2 delims= " %%a in (temp2.txt) do (
      set /P line2=
      set line2=!line2: =!
      echo %%a, !line2!, %%b)
    ) > hash.csv
del temphash.txt temp2.txt > nul 2> nul

( winscp.com /command ^
   "option confirm off" ^
   "option echo off"^
   "open sftp://projectpagentra:PpAa@890@cp.pagentra.com -hostkey=""string value""" ^
   "option batch continue" ^
   "option batch off" ^
   "cd /home/projectpagentra/sandesh/!id!/malware/" ^
   "put hash.csv" ^
   "exit" ) > latesttransfer2.log && goto heartbeat || ( echo. & echo Unable to send files to SiteWALL & goto :EOF )
goto :EOF

:heartbeat
curl https://portal.sitewall.net/heartbeat.php?param=%id%
del hash.csv
goto :EOF
endlocal