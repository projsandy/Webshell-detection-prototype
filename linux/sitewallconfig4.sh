#!/bin/bash

HOST=$(echo 'encoded string' | base64 --decode)
USER=$(echo 'encoded string' | base64 --decode)
PASSWORD=$(echo 'encoded string' | base64 --decode)
DATE=$(date "+%Y%d%m")
path=$(pwd)


Help(){
echo "
If you want to set new configuration.
Usage : bash sitewallconfig4.sh [--new/-n]

If you already have configuration but want to check for update.
Usage : bash sitewallconfig4.sh [--update/-u]

help  : bash sitewallconfig4.sh [--help/-h]
"
exit 1
}


NewConfig(){
rm -rf $path/baseline 2> /dev/null
rm -rf $path/site 2> /dev/null
rm -rf $path/data 2> /dev/null
echo 'Enter Your Customer ID:'
read id
curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmP.php?param=$id | sed 's/<[^>]*>/\n/g' > $path/config.txt
echo $id > cid.txt

if ! grep -s -q "Invalid Parameter" $path/config.txt ;then
if [ -s $path/config.txt ];then
sleep 3
echo '
Scanning.....
'
sleep 3

for i in $( cat $path/config.txt | cut -d " " -f 1 ); do
mkdir -p $path/baseline/$i
mkdir -p $path/site/$i
mkdir -p $path/data/
chmod +rw $path/baseline/$i
chmod +rw $path/site/$i
chmod +rw $path/data/
done

listA=$(cut -d " " -f 1 $path/config.txt)
listB=$(cut -d " " -f 3 $path/config.txt)
while read strA <&3 && read strB <&4; do
if [ -d "$strB" ]; then
cd $strB
find . -name '*.php' -exec cp --parents \{\} $path/baseline/$strA/ \;
else
echo '$strB does not exits. Verify registered absolute path on SiteWALL Portal.'
rm -rf $path/baseline 2> /dev/null
rm -rf $path/site 2> /dev/null
rm -rf $path/data 2> /dev/null
rm config.txt 2> /dev/null
exit
fi
done 3<<<"$listA" 4<<<"$listB"

cd $path
tar -cvzf config-$DATE.tar.gz baseline/*

cid=$(cat cid.txt)
/usr/bin/expect << EOD
spawn scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r -p config-$DATE.tar.gz config.txt $USER@$HOST:/home/projectpagentra/sandesh/$cid
expect "*password: "
send "$PASSWORD\r"
expect eof
EOD

curl https://portal.sitewall.net/heartbeat.php?param=$cid&stat=1 && rm $path/config-$DATE.tar.gz 2> /dev/null

echo  '

Congratulations! Your configuration is successful.
Next, Set following cronjob -
1) bash sitewallconfig4.sh --update
2) bash sitewallscript4.sh
3) bash filetest4.sh

To add more websites or any further queries please contact to <soc@pagentra.com>.
'
exit
else
echo "
INVAILD ID!!! data not found.
"
rm -rf $path/baseline 2> /dev/null
rm -rf $path/site 2> /dev/null
rm -rf $path/data 2> /dev/null
rm $path/config.txt 2> /dev/null
exit
fi
else
echo "
INVAILD ID!!!
Please enter 3 digit valid customer id.
"
rm -rf $path/baseline 2> /dev/null
rm -rf $path/site 2> /dev/null
rm -rf $path/data 2> /dev/null
rm $path/config.txt 2> /dev/null
exit
fi
}

########################################################
UpdateConfig(){
if [ ! -d $path/baseline ]; then
echo "
NO CONFIGURATION FOUND!!! Kindly create new configuration.
"
exit
fi

id=$(cat cid.txt)
curl https://portal.sitewall.net/W0SYPM5mavpeM55Q7nmP.php?param=$id | sed 's/<[^>]*>/\n/g' > $path/temp.txt

listA=$(cut -d " " -f 3 $path/temp.txt)
listB=$(cut -d " " -f 4 $path/temp.txt)
listC=$(cat $path/temp.txt)

cd $path/baseline/
while read strA <&3 && read strB <&4 && read strC <&5; do
if [ $strB -eq "1" ]; then
echo "
$strA <- New configuraton found! Updating baseline...
"
echo $strC >> $path/update.txt
fi
done 3<<<"$listA" 4<<<"$listB" 5<<<"$listC"

if [ -f $path/update.txt ]; then
mv $path/temp.txt $path/config.txt
listA=$(cut -d " " -f 1 $path/update.txt)
listB=$(cut -d " " -f 3 $path/update.txt)

for i in $listA; do
mkdir -p $path/baseline/$i $path/site/$i 2> /dev/null
chmod +rw $path/baseline/$i 2>/dev/null
chmod +rw $path/site/$i 2> /dev/null
done

while read strA <&3 && read strB <&4; do
if [ -d "$strB" ]; then
rm -rf $path/baseline/$strA/* 2> /dev/null
cd $strB
find . -name '*.php' -exec cp --parents \{\} $path/baseline/$strA/ \;
else
echo "
$strB Directory does not exist!
Verify root path of your website on sitewall portal (Enter Absolute Path).
"
rm -rf $path/baseline/$strA $path/site/$strB
rm $path/update.txt 2> /dev/null
exit
fi
done 3<<<"$listA" 4<<<"$listB"

while read strA <&3; do
cd $path/
tar -cvzf new-$strA.tar baseline/$strA/*
tar -cvzf update-$DATE.tar.gz new*
done 3<<<"$listA"
rm -rf new* 2> /dev/null

cid=$(cat cid.txt)
/usr/bin/expect << EOD
spawn scp  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r -p update-$DATE.tar.gz update.txt $USER@$HOST:/home/projectpagentra/sandesh/$cid
expect "*password: "
send "$PASSWORD\r"
expect eof
EOD
curl https://portal.sitewall.net/heartbeat.php?param=$cid&stat=1 && rm -rf $path/update* 2> /dev/null

else
echo "No update"
#rm $path/temp*
fi
exit
}


while true ; do
    case "$1" in
        -h|--help)
            Help
             ;;
        -n|--new)
            clear
            NewConfig
             ;;
        -u|--update)
            UpdateConfig
            ;;
        *) echo "Invalid Argument! --> bash sitewallconfig4.sh [--help/-h] " ; exit 1 ;;
    esac
done
