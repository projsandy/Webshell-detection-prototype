#!/bin/bash

path=$(pwd)
listA=$(cut -d " " -f 1 $path/customers.txt)
listB=$(cut -d " " -f 2 $path/customers.txt)

while read strA <&3 && read strB <&4; do
if [ ! -d "/home/projectpagentra/sandesh/$strA" ]; then
mkdir -p /home/projectpagentra/sandesh/$strA/

if [ $strB=="linux" ]; then
echo "New cust_id $strA is found initializing admin task ..."
cp vttest4.sh /home/projectpagentra/sandesh/$strA/
sed -i "s|cid=|cid=$strA|g" /home/projectpagentra/sandesh/$strA/vttest4.sh
sed -i "s|ext=|ext='tar.gz'|g" /home/projectpagentra/sandesh/$strA/vttest4.sh

elif [ $strB=="windows" ]; then
echo "New cust_id $strA is found initializing admin task ..."
cp vttest4.sh /home/projectpagentra/sandesh/$strA/
sed -i "s|cid=|cid=$strA|g" /home/projectpagentra/sandesh/$strA/vttest4.sh
sed -i "s|ext=|ext='zip'|g" /home/projectpagentra/sandesh/$strA/vttest4.sh
fi
else
echo "Admin task for cust_id $strA is alredy done"
fi

done 3<<<"$listA" 4<<<"$listB"
sleep 3

while read strA <&3 && read strB <&4; do
sleep 5
echo "
Lauching VirusTotal for cust_id $strA ..."
cd /home/projectpagentra/sandesh/$strA/
bash vttest4.sh
done 3<<<"$listA" 4<<<"$listB"

echo "
Today's tasks are done
"

exit 1
