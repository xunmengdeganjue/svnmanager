#! /bin/bash
################################################################################
#FUNCTION:                                                                     #
#The script is to dump the repositories that in the /home/svnroot/repos/develop#
# /home/svnroot/manage /home/svnroot/cdproject.                                #
#                     	    						       #
#DATE    :2015-02-25                                                           #
#AUTHOR  :LIQY                                                                 #
#DESCRIBTION	:                                                              #
#HISTORY :                                                                     #
#       DATE                  MODIFY                                   AUTH    #
#    2015-02-27       Add MANAGERROOT variable                         LIQY    #
#    2015-03-01       Add the version of the dump file to log file     LIQY    #
################################################################################

SOURCEPATH1="/home/svnroot/repos/develop"
#SOURCEPATH2="/home/svnroot/repos/manage"
SOURCEPATH2=""
#SOURCEPATH3="/home/svnroot/repos/skysoft"
SOURCEPATH3=""

empty=
space=$empty" "$empty

SOURCEPATH=${SOURCEPATH1}${space}${SOURCEPATH2}${space}${SOURCEPATH3}
CURPATH=`pwd`
DESTREPO=" "
MANAGERROOT="/home/svnroot/svnmanager"
DUMPDIR="/home/svnroot/dump"
SVNADMIN="/usr/local/subversion/bin/svnadmin"
SVNLOOK="/usr/local/subversion/bin/svnlook"

DUMPLOG=${MANAGERROOT}"/log/dump.log"
VERSIONLOG=${MANAGERROOT}"/config/RepoVersion"
HTTPCONF="/usr/local/apache2/conf/httpd.conf"
MD5NUM="/tmp/httpd.md5"
#Maybe you just need to change  the remotedumpdir's IP and the remoteroot's password

REMOTEIP="192.168.1.113"

DUMPROOT="/home/svnroot/dump"
REMOTEDUMPDIR=${REMOTEIP}":"$DUMPROOT

REMOTEROOTPWD="liqiyuan"

versionseg=""
dontdump_flag=""

#
#The function versionDeal is to check the version of the dest repo that need
#to be dumped.for example if the repo hello has 13 versions and you have dumped
#it when it is 10 version. now you want to dump it from 10 to 13version,so you 
#need use this function to get the 10:13 for your dumping.
#

versionDeal()
{
	
	[ ! -z $1 ] || echo "Please check the target directory!"
	echo "you want deal with $1 folder"
	
	repopath=$1
	reponame=`echo ${repopath##/*/}`
	echo "the dest repo's name is:$reponame" |tee -a $DUMPLOG
	###########################################################################################
	####check if the reponame is in the Reversion.log file
	ret=`cat $VERSIONLOG |grep -w $reponame`
	
	#echo "the result is :$?"
	#if [ $? -eq 1 ];then
	if [ -z "$ret" ];then
		echo "the ret is null!" |tee -a $DUMPLOG
		##write the right version of the reponame to the $VERSIONLOG file
		#oldversion=`svnlook history $repopath |head -n 3|tail -n 1 |awk '{print $1}'`
		#oldtemp=`svnlook history $repopath `
		#oldversion=`(echo $oldtemp) | awk '{print $7}'`
		oldversion=0
		echo "$reponame $oldversion" >> $VERSIONLOG
		version_flag=1
	else
		version_flag=0
		oldversion=`cat $VERSIONLOG |grep -w $reponame |cut -d " " -f 2`
	fi
	sleep 1
#	oldversion=`cat $VERSIONLOG |grep -w $reponame |cut -d " " -f 2`
	echo "the old version is $oldversion" |tee -a $DUMPLOG

	#newversion=`(svnlook history $repopath |head -n 3|tail -n 1 |awk '{print $1}') 2>/dev/null`
	#newversion=`svnlook history $repopath |head -n 3|tail -n 1 |awk '{print $1}' `
	#newversion=`svnlook youngest $repopath`
	newversion=`$SVNLOOK youngest $repopath`
	#newtemp=`(svnlook history $repopath) 2>/dev/null`
	#newversion=`(echo $newtemp)|awk '{print $7}'`
	echo "the latest version is $newversion" |tee -a $DUMPLOG
	if [ ${oldversion} -lt ${newversion} ];then
		vstart=`expr ${oldversion} + 1`
		echo "version start number is :$vstart" |tee -a $DUMPLOG
		dontdump_flag=0
	else
		vstart=$oldversion
		dontdump_flag=1
	fi

	versionseg=$vstart":"$newversion
	return $version_flag
}
accessDeal()
{
	repopath=$1
	reponame=`echo ${repopath##/*/}`
	cp ${repopath}/access $DUMPROOT/${reponame}/${reponame}"_access"

}
configDeal()
{
	#md5sum $HTTPCONF |awk '{print $1}' >/tmp/httpd.md5
	if [ -f $MD5NUM ];then	
		oldmdnum=`cat $MD5NUM `
	else
		oldmdnum=" "
		echo "$oldmdnum" > $MD5NUM	
	fi
	newmdnum=`md5sum $HTTPCONF |awk '{print $1}'`
	[ "${oldmdnum}"=="${newmdnum}" ] || cp $HTTPCONF $DUMPROOT/ ;echo "${newmdnum}" >$MD5NUM
			
}

dump()
{
	for i in $SOURCEPATH
	do
		cd $i
		echo "****************************************************************************"
		echo "Entering `pwd`" 
		###################################################################################
		##do the dumping###################################################################
		###################################################################################
		DESTREPO=`ls`
		#echo "the subdirs are:$DESTREPO"
		for j in $DESTREPO
		do 
			destdumpdir=${DUMPDIR}/$j
			destrepodir=$i/$j
			echo "the dest repodir is:$destrepodir"
			###########################################################################
			#####check the version of the repos for increatal dumping              ####
			########################################################################### 
			versionDeal $destrepodir
			echo "dontdump_flag is:::::::::::::::$dontdump_flag"
			
			echo "the versionsegment is:$versionseg"
			#[ -d $destdumpdir ] && rm -rf ${destdumpdir}
	#:<<dof
			if [ $dontdump_flag -eq 0 ];then

				if [ -d ${destdumpdir} ];then
					echo "delete the old $destdumpdir"
					rm -rf ${destdumpdir} 
				fi

				mkdir -p ${destdumpdir}
	#dof
				echo "make the ${destdumpdir}"
		
				accessDeal $destrepodir
				destdumpfile=${destdumpdir}/$j`date +"_%F"*"$versionseg"`".dump"
				echo "subdir is $j"
				echo "dest dumpfile is:$destdumpfile"
				
				####################################################################
				##Do the dumping                                                  ##
				####################################################################	
				${SVNADMIN} dump $i/$j -r $versionseg --incremental > $destdumpfile	

				####################################################################	
				#if the dumping is right then update the reversion of the destrepo##
				####################################################################
				if [ $? -eq 0 ];then
					echo "`date +"%F-%H:%M:%S"`-----Dump the $destrepodir successfully!" >> $DUMPLOG
					### write the newversion to the version file
					reponame=`echo ${destrepodir##/*/}`
					echo "the reponame 2 is:$reponame"
			       		#destnum=`nl $VERSIONLOG |sed -n '/\$reponame/p'`
			        	destnum=`nl $VERSIONLOG |grep -w $reponame|awk '{print $1}'`
					echo "the destnum is :$destnum"
					newversion=`($SVNLOOK history $destrepodir |head -n 3|tail -n 1 |awk '{print $1}') 2>/dev/null`
			        
					echo "the newversion is:$newversion"
					sed -i '/^$/d' $VERSIONLOG	#delete the blank line 
					sed -i "${destnum}c${reponame} ${newversion}" $VERSIONLOG
			        	echo "update the version of the $reponame to the $VERSIONLOG"
					####################################################################
					#####send the dump data to the remote backup server       ##########
					####################################################################	
:<<hello	
					sshpass -p ${REMOTEROOTPWD} ssh root@$REMOTEIP "cd $DUMPROOT;[ -d ${reponame} ] || mkdir -p /home/svnroot/dump/${reponame}"
			                sshpass -p ${REMOTEROOTPWD} scp ${DUMPROOT}/${reponame}/* root@${REMOTEDUMPDIR}/${reponame}/
					if [ $? -eq "0" ];then
						echo "`date +"%F-%H:%M:%S"`-----Send the ${destdumpdir} (`du -h $destdumpdir |awk '{print $1}'`) to ${REMOTEDUMPDIR}  successfully"|tee -a $DUMPLOG 
					else
						echo "`date +"%F-%H:%M:%S"`-----Send failed !" |tee -a $DUMPLOG
						echo "`date +"%F-%H:%M:%S"`-----I will try it again !" |tee -a $DUMPLOG
						sshpass -p ${REMOTEROOTPWD} scp ${DUMPROOT}/${reponame}/* root@${REMOTEDUMPDIR}/${reponame}/
						[ $? -eq "0" ] && echo "`date +"%F-%H:%M:%S"`-----Send succeed this time !" |tee -a $DUMPLOG \
						|| echo "`date +"%F-%H:%M:%S"`-----Send failed again!.Please check the remote server,maybe the disk is full or the net is disconnected " |tee -a $DUMPLOG
					fi
hello
					send_single $reponame
					
				fi
			else
				echo "`date +"%F-%H:%M:%S"`-----Skip the $destrepodir: This repository not been updated yet.So we wont dump it again." |tee -a $DUMPLOG
			fi
			sleep 1
		#	exit 1
		done
		echo "Leaving  `pwd`" 
		echo "****************************************************************************"  
		echo 
		sleep 1
	
	done
	configDeal 

}
send_single()
{
	targetrepo=$1
	echo "`date +"%F-%H:%M:%S"`-----Send the $targetrepo to the ${REMOTEDUMPDIR} [ START ]" |tee -a $DUMPLOG
	#sshpass -p ${REMOTEROOTPWD} ssh root@${REMOTEIP} "if [ ! -d $i ];then mkdir -p /home/svnroot/dump/$i fi;"
	##At first we must make sure that remote server has the folder /home/svnroot/dump
	sshpass -p $REMOTEROOTPWD ssh root@$REMOTEIP "[ -d $DUMPROOT ] || mkdir -p $DUMPROOT"
	sshpass -p $REMOTEROOTPWD ssh root@$REMOTEIP "cd $DUMPROOT;[ -d $targetrepo ] || mkdir -p /home/svnroot/dump/$targetrepo"
	sshpass -p ${REMOTEROOTPWD} scp $DUMPDIR/$targetrepo/* root@${REMOTEDUMPDIR}/$targetrepo/
	if [ $? -eq "0" ];then
		echo "`date +"%F-%H:%M:%S"`-----Send the ${targetrepo}[ v:`echo $DUMPDIR/$targetrepo/*.dump |cut -d "." -f 1|cut -d "*" -f 2`] (`du -h $DUMPROOT/$targetrepo |awk '{print $1}'`) to ${REMOTEDUMPDIR}  successfully [ END]"|tee -a $DUMPLOG 
	else
		echo "`date +"%F-%H:%M:%S"`-----Send failed !" |tee -a $DUMPLOG
		echo "`date +"%F-%H:%M:%S"`-----I will try it again !" |tee -a $DUMPLOG
		sshpass -p ${REMOTEROOTPWD} scp ${DUMPROOT}/${targetrepo}/* root@${REMOTEDUMPDIR}/${targetrepo}/
		[ $? -eq "0" ] && echo "`date +"%F-%H:%M:%S"`-----Send succeed this time !" |tee -a $DUMPLOG \
		|| (echo "`date +"%F-%H:%M:%S"`-----Send failed again!.Please check the remote server,maybe the disk is full or the net is disconnected [ ERROR ]" |tee -a $DUMPLOG;return 1)
	fi
	return 0
}
send_all()
{
	cd $DUMPDIR
	copydumpdir=`ls`
	for i in $copydumpdir
	do
		send_single $i
	done

}
version_update()
{
	for i in $SOURCEPATH
	do 
		cd $i
		repolist=`ls`
		for j in $repolist
		do
			reponame=$j
			destrepopath=$i/$reponame
			versionDeal $destrepopath
			if [ $? -eq 0 ];then	
				sed -i '/^$/d' $VERSIONLOG #delete the blank lines	
				newversion=`$SVNLOOK youngest $destrepopath`
				destnum=`nl $VERSIONLOG |grep -w $reponame|awk '{print $1}'`
				echo "the newversion is:$newversion"	
				sed -i "${destnum}c${reponame} ${newversion}" $VERSIONLOG
			    echo "update the version of the $reponame to the $VERSIONLOG"
			fi
		done
		
	done

}
case $1 in
"send")
	send_all
	;;

"dump")
	echo "Stop the httpd to protect the repos data from polluting" |tee -a $DUMPLOG
	service httpd stop
	ps aux |grep httpd |grep -v grep >/dev/null 2>&1
	[ $? -eq 0 ] && (echo "kill the HTTPD again" |tee -a $DUMPLOG; killall httpd )
	ps aux |grep httpd |grep -v grep >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Maybe The svnserver is still been useing.Can't do the dumping" |tee -a $DUMPLOG
	else
		dump
		echo "Start the httpd"|tee -a $DUMPLOG
		service httpd start
		[ $? -eq 0 ] &&echo "Httpd started successfully!"|tee -a $DUMPLOG || echo "Httpd started failed!"|tee -a $DUMPLOG
		echo "" >> $DUMPLOG
	fi
	;;

"version_update")
	version_update
	;;

	*)
	echo "USAGE:"
	echo "     $0 <dump|send|version_update>"
	;;
esac





