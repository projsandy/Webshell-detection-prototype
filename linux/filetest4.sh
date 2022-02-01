#/bin/bash

HOST=$(echo 'encoded string' | base64 --decode)
USER=$(echo 'encoded string' | base64 --decode)
PASSWORD=$(echo 'encoded string' | base64 --decode)
DATE=$(date "+%Y%d%m")
path=$(pwd)
export PATH="bin:${PATH}"

if [ -f cid.txt ]; then
cid=$(cat cid.txt)
curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmhj.php?param=$cid | sed 's/<[^>]*>/\n/g' > path.txt

listA=$(cut -d " " -f 1 path.txt)
listB=$(cut -d " " -f 2 path.txt)

while read strA <&3 && read strB <&4; do
if [ -f $strB ]; then
echo "$strA  $(md5sum $strB)" >> hash.csv
else
echo "$strA  NOT-FOUND  $strB" >> hash.csv
fi
done 3<<<"$listA" 4<<<"$listB"

if [ -f hash.csv ]; then
sed -i "s|  |, |g" hash.csv
/usr/bin/expect << EOD
spawn scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r -p hash.csv $USER@$HOST:/home/projectpagentra/sandesh/$cid/malware/
expect "*password: "
send "$PASSWORD\r"
expect eof
EOD
curl https://portal.sitewall.net/heartbeat.php?param=$cid&stat=3 && rm hash.csv
fi
#rm path.txt

else
echo "
Cust_ID NOT FOUND!
"
fi