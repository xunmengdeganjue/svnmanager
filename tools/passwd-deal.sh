#! /bin/bash
################################################################################
#FUNCTION:The script is to add the users and their passwd into the passwdfile. #
#the original passwd of the user is same as the user name.                     #
#DATE    :2013-08-27                                                           #
#AUTHOR  :LIQY                                                                 #
#HISTORY :                                                                     #
#       DATE 	              MODIFY	               AUTH                    #
#   2013-08-28        Change the PWDFILE source       -LIQY-                   #
################################################################################
HTPASSWD=/usr/local/apache2/bin/htpasswd
cat << information
********************************************************************************
This script is to get the users from the access file,then add all the users with 
their password into the passwd-file[PWDFILE].The default passwd-file is located
in the /home/svnroot/repos/.The user group[USER_GROUP] contains the RDS-CM RDS-
manage RDS-develop RDS-QA they are from the access file,if the detail group name
 is changed you must change them in this script,or you can't get the right result.
********************************************************************************
information
sleep 1

#PWDFILE="/home/svnroot/repos/user-all.passwd"
PWDFILE=`ls /home/svnroot/repos/*.passwd`

USER_SOURCE=$1

#USER_GROUP THIS PARAMETER'S VALUE DEPEND ON THE ACCESS FILE'S PARAMETERS
#USER_GROUP="RDS-CM RDS-Manage RDS-Develop RDS-QA"
USER_GROUP="OCM CM PM PG QA O_READ"
USER_LIST=""
SPACE=" "

###############################################################################
##if there are more than one *.passwd file then must check the right passwd file 
##out or the htpasswd command can't work
###############################################################################
COUNT=`echo $PWDFILE | awk -F" " '{print NF}'`
COUNT=`expr $COUNT - 1 `
if [ $COUNT -ge 0 ];then
        for a in $PWDFILE
        do
                echo $a |grep -q "back"
                if [ ! $? -eq 0 ];then
                PWDFILE=$a
                fi
        done
fi
echo "passwdfile:$PWDFILE"
################################################################################
#Get the value of the USER_GROUP(developer list),that is sepearted by ',' then #
#change the separated-Flag to space and then give the result to the variable   # 
#USER_LIST							               #	
################################################################################
j=0
for i in $USER_GROUP
do
	let j++;
#	echo $j
#	echo $i
	#############################################################
	#get the value of the variable to be tmp value then check wh-
	#ether it contains the comma(,).
	#############################################################
	user_tmp=`(cat $USER_SOURCE) |grep "^$i" | awk -F'=' '{print $2}'`
	num_comma=`echo $user_tmp | awk -F',' '{print NF}'`
	num_comma=`expr $num_comma - 1`
	if [ $num_comma -eq 0 ];then
		if [ $j = 1 ];then #The first circle
			USER_LIST=$USER_LIST$SPACE$user_tmp
			continue
		else
		#############################################
		#check whether the user_tmp already exists in
		#the $USER_LIST
		############################################
			for u in $USER_LIST
			do
				if [ $u = $user_tmp ];then
					echo "the user:$u exist!"
					break	
				fi
			done
			USER_LIST=$USER_LIST$SPACE$user_tmp
		fi
	else
		user_tmp=`echo $user_tmp | sed "s/,/ /g"`
		if [ $j -eq 1 ];then #The first circle
			USER_LIST=$USER_LIST$SPACE$user_tmp
		else
			for v in $user_tmp
			do	
				#echo "v:$v"
				for w in $USER_LIST
				do
					#echo "w:$w"
					if [ "$w" = "$v" ];then
					#	echo "user:$v exists!!!!!!"
						user_exist_flag=1
						break 
					fi
				done
				if [[ $user_exist_flag -eq 1 ]];then
					user_exist_flag=0
					continue
				else	
					USER_LIST=$USER_LIST$SPACE$v
					user_exist_flag=0
				fi
			done
		fi	
	fi
done
echo $USER_LIST
################################################################################
#Add the user in a circle but check whether the user already exists.if the user#
#doesn't exist add it,or do not.                                               #
################################################################################
for i in $USER_LIST
do
	#echo $i
        #############################################################
	#judge if the user exists,if it exist continue the          #
	#circle,or add the user to the passwdfile.		    #
	#############################################################
	#line=`sed -n "/^$i/=" $PWDFILE`
	line=`( cat $PWDFILE ) | sed -n "/^$i/="`
	#if the length of the line is not zero means the user exists.
	if [ ! -z "$line" ] #here same as [ -n "$line"]
	then 
	 	echo "the user '$i' already exists!"
		continue
	fi
	#############################################################
	#add the user and it's passwd to the passwd-file($PWDFILE)  #
	#############################################################
	if [ -f $PWDFILE ];then
		#if the passwd-file exists add the user with password 
		$HTPASSWD -b $PWDFILE $i $i
	else
		#if the passwd-file doesn't exist then creat it.
		$HTPASSWD -cb $PWDFILE $i $i
	fi

done

