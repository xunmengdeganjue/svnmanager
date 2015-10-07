#! /bin/bash
CONFIG="/home/svnroot/svnmanager/test/httpd.conf"


line=`nl $CONFIG |grep 2014-test1 |head -n 1|awk '{print $1}'`
echo "the line is :$line"
linestart=`expr $line - 1`
echo "the linestar is:$linestart"
lineend=`expr $linestart + 10`
echo "the lineend is :$lineend"
#delete the bland line of the dest file

sed '/^$/d' $CONFIG
#delete the specific lines of the $CONFIG
sed -i "$linestart,${lineend}d" $CONFIG




