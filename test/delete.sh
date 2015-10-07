#! /bin/bash
REPOROOT="/home/svnroot/repos"
SOURCE1=$REPOROOT/develop
SOURCE2=$REPOROOT/manage
SOURCE3=$REPOROOT/skysoft

empty=
space=$empty" "$empty

SOURCE=${SOURCE1}${space}${SOURCE2}${space}${SOURCE3} 

####
#delete all the repostories
#
for i in ${SOURCE}
do 
	cd $i
	echo "delete all repos in the $i "
	rm -rf ./*
	
done


