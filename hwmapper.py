#!/usr/local/bin/python
import sys

for line in sys.stdin:
    data = line.strip().split()
    print data[0]+"\t"+data[1]
