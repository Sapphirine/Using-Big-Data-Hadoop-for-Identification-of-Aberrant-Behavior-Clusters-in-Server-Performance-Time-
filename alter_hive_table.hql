—Hive table alter command for CPU, MEM and PROC
use database;
alter table cpu add partition(ymd=${YMD}) location 'nmon_cpu_DT.bz2'; 
alter table mem add partition(ymd=${YMD}) location 'nmon_mem_DT.bz2'; 
alter table proc add partition(ymd=${YMD}) location 'nmon_proc_DT.bz2';
