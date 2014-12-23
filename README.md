Using-Big-Data-Hadoop-for-Identification-of-Aberrant-Behavior-Clusters-in-Server-Performance-Time-
==================================================================================================
The system described in this project is a collection of scripts written in PIG, HIVE, python and R for use in the Extract Load Transform methodology. The goal of the methodology is to produce in a parallel computational environment, Hadoop for this project, a feature vector set of server aberrant performance behavior metrics for time series data. These feature vectors can then be used by the Mahout cluster algorithms for further discovery.

The methodology progresses through the following stages:
Extract
Extraction of the NMON server performance data will vary by organizational data center setup. Typically the organization will run the NMON program via a schedular such as cron to accommodate the creation of a daily NMON data file. Please see the following link for more examples of running NMON: http://nmon.sourceforge.net/pmwiki.php?n=Site.GettingStarted
NMON daily collection files are usually stored by an organizational central repository collection server, again details will be dependent on the organizational infrastructure.
Load
The script: collect_nmon_files.sh is used to concatenate and compress ( note the use of bzip2 as this compression algorithm can be split for map jobs in compressed form ) the NMON files into a single single file data with server name and timestamp appended to each line. This single file facilitates storing large files in Hadoop Distributed File System(HDFS) to the benefit of reduced HDFS name service  memory.
The collect_nmon_files.sh script also executes the Hadoop command line hdfs utility to transfer the large compressed collection file from local filesystem into the HDFS.
Transform
The transformation stage starts with the transform of NMON data from log format into a tabular format by metric for hive table insertion. See back to section 3 for an illustration of this step. The Hadoop PIG system with the execution of nmon2HiveFormat.pig is used to produce the tabular format files. At this point or prior due to the use of external tables, the HIVE scripts hive_create_tables.hql and alter_hive_table.hql will be executed with the command line hive -f ./hive_create_tables.hql.
Once the hive tables are configured, hive is then used for data aggregation and stream transform to accomplish the creation of the HoltWinters aberrant data point percentage as described in section 4. The script hiveStream2R.hql , which calls hwmapper.py for the map stream and rm_convert.R for the reduce stream, is executed with hive -f ./hiveStream2R.hql . Note, separate executions for each metric will occur to generate the aberrant percentage data. The separate files will then be concatenated into one using the create_csv.py python script.
Mahout is used for further transformation of the aberrant data into clusters. Use of the create_feature_vectors.sh and run_the_ks.sh scripts facilitate the creation of multiple k size cluster groups. The chart_graphml.R script is provide as an example to chart the Mahout clusterdump created “graphml” formated files.

To summerzie the following is the generally proposed execution sequence for the ELT scripts ( note alteration of the scripts will be needed to fit the actual runtime environment):
collect_nmon_files.sh
nmon2HiveFormat.pig
hive_create_tables.hql
alter_hive_table.hql
hiveStream2R.hql
create_csv.py
create_feature_vectors.sh
run_the_ks.sh
chart_graphml.R
