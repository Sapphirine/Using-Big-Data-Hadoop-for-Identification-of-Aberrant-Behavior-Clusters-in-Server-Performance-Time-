#!/bin/sh
# execute several kmeans cluster creation

for k in 3 32 512 1024 
do
   echo $k
   hdfs dfs -rmr /user/tmp/*
   mahout kmeans   --input project/data   --output project/kmeans-output   -k $k  -ow --clusters project/output/clusters-kmeans-clusters --maxIter 60  --method mapreduce   --distanceMeasure org.apache.mahout.common.distance.CosineDistanceMeasure --clustering

   mahout clusterdump -i project/kmeans-output/clusters-1-final -o Projectanalysiskm_${k}.txt -p project/kmeans-output/clusteredPoints -e > km_dump_${k}.out 2>&1

   mahout clusterdump -i project/kmeans-output/clusters-1-final -of GRAPH_ML -o Projectanalysiskm_${k}.graphml -p project/kmeans-output/clusteredPoints

done
