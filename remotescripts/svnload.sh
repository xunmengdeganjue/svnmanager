#! /bin/bash

:<<eof
DUMPROOT="/home/svnroot/dump"
ACCESSROOT="/home/svnroot/svnmanager/access"
MANAGERROOT="/home/svnroot/svnmanager"
REPOROOT="/home/svnroot/repos/develop"
SVNADMIN="/usr/local/subversion/bin/svnadmin"
LOADLOG="/home/svnroot/svnmanager/log/load.log"
eof

CURDIR=`pwd`
source ${CURDIR}/config/rule


createRepo()
{
	cd $DUMPROOT
	repolist=`ls`
	for i in $repolist
	do
		destrepo=$REPOROOT/$i
		###############################################################
		###check if the destrepo already exist#########################
		###############################################################
		if [ ! -d $destrepo ];then 
			mv $DUMPROOT/$i/*access $ACCESSROOT/
			[ $? -eq 0 ] && echo "`date +"%F-%H:%M:%S"`----Move the [${i}_access] successfully!" >> $LOADLOG||echo "`date +"%F-%H:%M:%S"`----Move the [${i}_access] failed ">>$LOADLOG
			cd $MANAGERROOT
			sh svncreate develop $i	
			[ $? -eq 0 ] && echo "`date +"%F-%H:%M:%S"`-----Create the repository [${destrepo}] successfully!" |tee -a $LOADLOG \
			|| echo "`date +"%F-%H:%M:%S"`-----Create the repostory [${destrepo}] failed!" |tee -a $LOADLOG
		else
			echo "`date +"%F-%H:%M:%S"`-----The target repostory [${destrepo}] already exists!" |tee -a $LOADLOG
		fi
		
	done

}

loadDumpFile()
{
	cd $DUMPROOT
	repolist=`ls`
	if [ -z "${repolist}" ];then
		echo "`date +"%F-%H:%M:%S"`-----ERROR :There is no dump file in the $DUMPROOT folder" |tee -a $LOADLOG
		exit 1
	fi
	echo |tee -a $LOADLOG
	echo "`date +"%F-%H:%M:%S"`-----Now let's start to do the loading" | tee -a $LOADLOG
	for i in ${repolist}
	do
		cd $i
		echo "`date +"%F-%H:%M:%S"`-----Enter the folder [ `pwd`/$i ]" |tee -a $LOADLOG
		dumplist=`ls`
		if [ -z "${dumplist}" ];then
			cd ..
			echo  "`date +"%F-%H:%M:%S"`-----No data to recover .Leaving the folder [ `pwd`/$i ]" |tee -a $LOADLOG
			echo |tee -a $LOADLOG
			continue 
		fi
		
		#suffix=`echo $j |awk -F"_" '{print $NF}'`
                #if [ "$suffix" == "access" ];then
                #        mv $j $ACCESSROOT/
                #        continue
                #fi

		for j in ${dumplist}
		do	
			suffix=`echo $j |awk -F"_" '{print $NF}'`
			if [ "$suffix" == "access" ];then
				mv $j $ACCESSROOT/
				echo "`date +"%F-%H:%M:%S"`-----Move the  [$j] to the $ACCESSROOT folder!" >> $LOADLOG
				continue
			fi
			echo "`date +"%F-%H:%M:%S"`-----[ START ] Load the [$j]" >> $LOADLOG
			$SVNADMIN load $REPOROOT/$i < $j 
			if [ $? -eq 0 ];then
				echo "`date +"%F-%H:%M:%S"`-----[ END ] Load [$j] successfully![ SUCCEED ]" |tee -a $LOADLOG
				rm -rf $j
				[ $? -eq 0 ] && echo "`date +"%F-%H:%M:%S"`-----Delete the [$j] successfully!" |tee -a $LOADLOG \
				|| echo "`date +"%F-%H:%M:%S"`-----Delete the [$j] failed" |tee -a $LOADLOG
			else
				sleep 1
				#echo "load the $j " >> $LOGFILE
				$SVNADMIN load $REPOROOT/$i < $j
				[ $? -eq 0 ] && echo "`date +"%F-%H:%M:%S"`-----Second time load [$j] successfully!" |tee -a $LOADLOG \
				||echo "`date +"%F-%H:%M:%S"`-----[ END ] Load [$j] failed again![ FAILED ]" |tee -a $LOADLOG
			fi
		done
		echo "`date +"%F-%H:%M:%S"`-----Leaving the folder [ `pwd`/$i ]" |tee -a $LOADLOG
		echo |tee -a $LOADLOG
		cd ..
	done

}


case $1 in
"all")
	echo "**********************************************************************************" |tee -a $LOADLOG
	createRepo
	loadDumpFile
	echo "**********************************************************************************" |tee -a $LOADLOG
	echo |tee -a $LOADLOG
;;

"load")
	echo "**********************************************************************************" |tee -a $LOADLOG
	loadDumpFile
	echo "**********************************************************************************" |tee -a $LOADLOG
	echo |tee -a $LOADLOG
;;

"create")
	echo "**********************************************************************************" |tee -a $LOADLOG
	createRepo
	echo "**********************************************************************************" |tee -a $LOADLOG
	echo |tee -a $LOADLOG
;;
esac





