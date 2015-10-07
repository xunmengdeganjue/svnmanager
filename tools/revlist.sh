#! /bin/bash

#####get all of the repostories's versions


#REPOROOT="/home/svnroot/repos"
#SOURCE1=$REPOROOT/develop
#SOURCE2=$REPOROOT/skysoft
#SOURCE3=$REPOROOT/manage

cur_dir=$(cd "$(dirname "$0")"; pwd)
echo "$0 is  in $cur_dir"
cd $cur_dir
source ../config/rule


for i in $SOURCEPATH
do
	cd $i
	destrepolist=`ls`
	for j in ${destrepolist}
	do
		destrepopath=$i/$j
		destversion=`(svnlook history $destrepopath |head -n 3 |tail -n 1|awk '{print $1}') 2>/dev/null`
		echo "name:$j version:$destversion"
	done
done


