#! /bin/bash
version=""
HTTPCONF="/usr/local/apache2/conf/httpd.conf"
<<eof
for i in 1 2 3 4 5
do

	version=`(svnlook history /home/svnroot/repos/develop/2014-test/ |head -n 3 |tail -n 1 |awk '{print $1}') 2>/dev/null  `
	echo "$i The version is $version"
	sleep 1

done


eof


md5sum $HTTPCONF |awk '{print $1}' >/tmp/httpd.md5





