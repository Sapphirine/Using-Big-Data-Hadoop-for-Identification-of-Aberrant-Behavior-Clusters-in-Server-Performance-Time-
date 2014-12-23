#!/usr/local/bin/python
# script to concat 3 dat files into one by first column, first data file via stdin
import sys
import subprocess

for line in sys.stdin:
    words = line.strip().split()
    #for word in words[:2]:
    #    print "%s\t" % (word.lower()),
    result = subprocess.check_output(["grep",words[0],”datafile2.dat"])
    memdata = result.strip().split()
    result = subprocess.check_output(["grep",words[0],”datafile3.dat"])
    procdata = result.strip().split()
    print words[0]+","+words[1]+","+memdata[1]+","+procdata[1]
