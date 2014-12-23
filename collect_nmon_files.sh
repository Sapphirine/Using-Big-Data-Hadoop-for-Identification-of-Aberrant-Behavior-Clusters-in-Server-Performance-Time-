#!/bin/sh
# Shell script to wrap a collection of nmon files into 1 file for HDFS storage
# File will be concatenation of all single nmon file data with server name and
# timestamp appended to each line
# File will then be bzip2 for compressed storage
# Note: directories will need to be altered for use in other environments
for file in `ls collected/`
        do
                filename=`echo $file | awk -F'_' '{ print $1 }'`
                DT=`echo $file | awk -F'_' '{ print $2 }'`
                #echo $filename $DT
                awk -v filename=$filename -v dt=$DT '{ print filename","dt","$0 }' collected/$file 
        done | bzip2 > nmonLinuxCollection.bz2

hdfs dfs -put nmonLinuxCollection.bz2 /user/hdfs/nmonlinux/nmonLinuxCollection.bz2"

