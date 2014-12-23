#!/bin/sh
# use mahout arff.vector routine to translate arff file to vectors
cp cluster_data.csv cluster_data.arff
vi cluster_data.arff 
hdfs dfs -put cluster_data.arff hwCluster/cluster_data
hdfs dfs -put cluster_data.arff clusterData
mahout arff.vector -d clusterData -o clusterData/data -t clusterData/dict
cp cluster_data.arff clusterData.arff
cp cluster_data.arff clusterData
mahout arff.vector -d clusterData -o clusterData/data -t clusterData/dict
mahout arff.vector -d clusterData -o clusterData/data -t clusterData/dict
cp cluster_data.arff project/
hdfs dfs -put project/cluster_data.arff project
mahout arff.vector -d project -o project/data -t project/dict

