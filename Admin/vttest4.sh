#!/bin/bash
DATE=$(date "+%Y%d%m")
cid=
ext=
cd /home/projectpagentra/sandesh/$cid

echo "
Housekeeping task for cust_id $cid is under process...
"

mkdir -p malware malware/buffer/ archive archive/config/ archive/update/ archive/buffer 2> /dev/null


if [ -f config.txt ]; then 
mv config-*.$ext archive/config/ 2> /dev/null
fi

if [ -f update.txt ]; then
mv update-*.$ext archive/update/ 2> /dev/null
listA=$(cut -d ' ' -f 3 update.txt)
listB=$(cut -d ' ' -f 1 update.txt)
listC=$(cat update.txt)

while read -r strA <&3 && read -r strB <&4 && read -r strC <&5; do
a=$(grep $strB config.txt | cut -d ' ' -f 3)
grep "$strB" config.txt > temp.txt
if [ -s temp.txt ];then
sed -i "s|$a|$strA|g" config.txt
else
echo $strC >> config.txt
fi
done 3<<<"$listA" 4<<<"$listB" 5<<<"$listC"
rm temp.txt
fi


if [ -f buffer-$DATE.txt ]; then
listA=$(cut -d ' ' -f 1 buffer-$DATE.txt)
listB=$(cut -d ' ' -f 3 buffer-$DATE.txt)

echo "------------------------------" >> malware/VToutput.log
date >> malware/VToutput.log
while read -r strA <&3 && read -r strB <&4; do
echo $strB
curl -s -X POST 'https://www.virustotal.com/vtapi/v2/file/report' --form apikey="ccc44785cf65deddfd83082dd0603737d607aa530eb2effe38319aca3d33eed1" --form resource="$strA" > output.txt
echo $strA $strB >> malware/VToutput.log
cat output.txt | jq -r '.verbose_msg' >> malware/VToutput.log
echo "positive detection :" $(cat output.txt | jq -r '.positives') >> malware/VToutput.log

if ! grep -s -q '"response_code": 0' output.txt ;then
if ! grep -s -q '"positives": 0' output.txt ;then
#echo "Cust_ID, Timestamp, /customer/sitewall/directory, Site_ID, Malicious file, Input hash, Input sha256, Url, Unique signatures" >> malware/temp.csv
echo "$cid, $(date), $strB, $strA, $(cat output.txt | jq -r '.sha256'), $(cat output.txt | jq -r '.permalink'), $(cat output.txt | jq '.scans | .[] | select(.detected==true)' | jq -r '.result' | sort -u  | tr '\n' '|')" >> malware/temp.csv
mv buffer-$DATE.$ext malware/buffer/ 2> /dev/null
fi
fi
sleep 30
done 3<<<"$listA" 4<<<"$listB"



if [ -f malware/temp.csv ]; then
echo "Malware found in the buffer."
listC=$(cut -d ' ' -f 1 config.txt)
listD=$(cut -d ' ' -f 3 config.txt | tr '\\' '/')
listE=$(cut -d ' ' -f 5 config.txt)

while read -r strC <&3 && read -r strD <&4 && read -r strE <&5; do
#sed -i "s|site/| malware --> |g" malware/malware.txt
sed -i "s|$strC|, $strE, $strC, $strD|g" malware/temp.csv
done 3<<<"$listC" 4<<<"$listD" 5<<<"$listE"

cut -d ',' -f 3 --complement malware/temp.csv > malware/temp2.csv
cat malware/temp2.csv | tr '\\' '/' >> malware/malware.csv
rm malware/temp.csv
rm malware/temp2.csv
else
echo "No malware found inside buffer"
fi
rm output.txt 2> /dev/null
mv buffer-* archive/buffer/ 2> /dev/null
else
echo "No buffer reported in Cust_ID $cid on $(date)"
fi

