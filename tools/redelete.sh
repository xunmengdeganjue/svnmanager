#! /bin/bash

###############################################################################
#delete all of the test repostories in the svnserver                          #                             
###############################################################################

REPOROOT="/home/svnroot/repos"
#REPOROOT="/home/svnroot_test/repos"

SOURCE1=$REPOROOT/develop
SOURCE2=$REPOROOT/manage
SOURCE3=$REPOROOT/skysoft
empty=
space=$empty" "$empty
SOURCE=$SOURCE1$space$SOURCE2$space$SOURCE3
DELETELOG="/home/svnroot/svnmanager/log/delete.log"
CONFIG="/usr/local/apache2/conf/httpd.conf"
#CONFIG="/home/svnroot/svnmanager/test/httpd.conf"
VERSIONLOG="/home/svnroot/svnmanager/config/RepoVersion"
singleDelete()
{

	reponame=$1
	##locate the dest repo
	destrepo=`find $REPOROOT -name "$reponame" -type d ` #get the path of the reponame

	##delete the dest repo
	echo "`date +"%F-%H:%M:%S"`----Delete the ${destrepo}" |tee -a $DELETELOG
	[ -d $destrepo ] && rm -rf $destrepo || exit 1
	[ $? -eq 0 ] && echo "`date +"%F-%H:%M:%S"`----Delete $destrepo successed!" |tee -a $DELETELOG \
	|| (echo "`date +"%F-%H:%M:%S"`----Delete $destrepo failed!" |tee -a $DELETELOG ;exit)
	##locate the config content
	line=`nl $CONFIG |grep $1 |head -n 1|awk '{print $1}'`
	linestart=`expr ${line} - 1`
	echo "the linestar is:${linestart}"
	lineend=`expr ${linestart} + 10`
	echo "the lineend is :${lineend}"
	#delete the blank lines of the dest file
	sed -i '/^$/d' $CONFIG 
	##delete the config content of the repo
	sed -i "${linestart},${lineend}d" $CONFIG 
	##delete the record of the repo from the $VERSIONLOG
	sed -i "/${reponame}/d" $VERSIONLOG

}


allDelete()
{
	for i in $SOURCE
	do
		cd $i
		repolist=`ls`
		for j in $repolist
		do
			singleDelete $j	
					
		done
		cd ..
	done
}


case $1 in
"all")
	allDelete
	service httpd restart
;;
"single")
	echo "delete the $2"
	singleDelete $2	
	service httpd restart
;;

*)
echo "USAGE:"
echo "      sh $0 all                 ----delete all the repostories"
echo "      sh $0 single repo-target  ----delete the single repostory target"
;;

esac




