#! /bin/bash

#
#This script is used by the backup server
#It's to check the version of the dump file of the svn Repositors.
#Every repository just hold two nearest versions.The other versions need to
#be deleted.


DUMPROOT="/home/svnroot/dump"


cd ${DUMPROOT}
echo "the root dump dir is:${DUMPOROOT}"
repolist=`ls`
echo "enter the ${repolist}"
echo "I am in the foleder `pwd`"
for i in ${repolist}
do
	destrepo=$i
	#cd ${DUMPROOT}/${destrepo}
	cd ${DUMPROOT}/${destrepo}
	echo "entering the folder ${destrepo}"
	dumpfilelist=`ls`
	echo "dumpfilelist is ${dumpfilelist}"
	for j in ${dumpfilelist}
	do
		##here check the version of the dump file
		##delete the old version dump file
		
		destdumpfile=$j
		year=`echo ${var##2*_}|awk -F "-" '{print $1}'`
		date=`echo ${var##2*_}|awk -F "-" '{print $2}'`

		
		echo "the dest repo is  ${destdumpfile}	"
		






	done	
done 
