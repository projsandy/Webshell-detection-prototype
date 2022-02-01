#!/bin/bash

HOST=$(echo 'encoded string' | base64 --decode)
USER=$(echo 'encoded string' | base64 --decode)
PASSWORD=(echo 'encoded string' | base64 --decode)
DATE=$(date "+%Y%d%m")
path=$(pwd)
cid=$(cat cid.txt)
export PATH="bin:${PATH}"

if [ -f $path/config.txt ]; then
listA=$(cut -d " " -f 1 config.txt)
listB=$(cut -d " " -f 3 config.txt)

while read strA <&3 && read strB <&4; do
if [ -d $strB ]; then
cd $strB
else
echo "
$strB does not exits. Verify registered absolute path on SiteWALL Portal.
"
exit
fi
find . -name '*.php' -exec cp --parents \{\} $path/site/$strA/ \; 2> /dev/null
done 3<<<"$listA" 4<<<"$listB"
cd $path
diff -qrN $path/site/ $path/baseline/ | cut -f2 -d' ' > output.txt
else
echo "
NO CONFIG DATA FOUND.
"
exit
fi

if [ -s output.txt ];
then
#echo "file is not empty"
b=$(cut -d "/" -f 5 output.txt)
a=$(cat output.txt)
while read line1 <&3 && read line2 <&4; do
cp -rp $line1 data/ 2> /dev/null
md5sum $line1 >> buffer-$DATE.txt
done 3<<<"$a" 4<<<"$b"
rm output.txt 2> /dev/null

cd $path
tar -czvf buffer-$DATE.tar.gz data/*

echo "

Modified files found. Do not press any key, sending files to SiteWALL for analysis...

"
sleep 3
/usr/bin/expect << EOD
spawn scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r -p buffer-$DATE.tar.gz buffer-$DATE.txt $USER@$HOST:/home/projectpagentra/sandesh/$cid/
expect "*password: "
send "$PASSWORD\r"
expect eof
EOD
curl https://portal.sitewall.net/heartbeat.php?param=$cid&stat=2 &&
(
rm -rf $path/baseline/* 2> /dev/null
cp -rp $path/site/* $path/baseline/
while read strA <&3; do
rm -rf $path/data/* 2> /dev/null
rm -rf $path/site/$strA/* 2> /dev/null
done 3<<<"$listA"
rm -rf buffer-* 2> /dev/null
exit
) || ( echo "Unable to siend files to SiteWALL" )

else

curl https://portal.sitewall.net/heartbeat.php?param=$cid&stat=2 &&
(
echo "

All looks good!

"
while read strA <&3; do
rm -rf $path/data/* 2> /dev/null
rm -rf $path/site/$strA/* 2> /dev/null
done 3<<<"$listA"
rm -rf buffer-* 2> /dev/null
rm output.txt 2> /dev/null
exit
)
fi
