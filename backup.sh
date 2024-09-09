#!/bin/bash
set -ex
slsIP=192.168.0.45
tokenSLS="token" #insert here token from sls
backupPath=$(date +%Y%m%d_%H%M)
fileSLSBackup=backup_$backupPath.sls
dir="backup/sls/"
mkdir $dir$backupPath
# bakcup all Files
url="$slsIP/api/storage?token=$tokenSLS&path=/"
result=$(curl $url 2>/dev/null)
if [ $(echo $result | jq ".success")  = "true" ]; then 
	data=$(echo $result | jq -c -r ".result[]")
	for i in $data; do
		if [ $(echo $i | jq -c -r ".is_dir") = "false" ]; then
			f=$(echo $i | jq -c -r ".name")
			echo $f
			curl -o ./$dir$backupPath/$f $url$f 2>/dev/null
			#break
		fi
	done
else
	echo Error request
fi
# native backup
url=$slsIP/api/backup
get="token=$tokenSLS&action=create&config=1&zigbee=1"
curl -d $get -o ./$dir$backupPath/$fileSLSBackup $url 2>/dev/null
if [ -f "./$dir$backupPath/$fileSLSBackup" ]; then
	echo $fileSLSBackup
else
	echo Error request for native backup: File Not Found
fi
