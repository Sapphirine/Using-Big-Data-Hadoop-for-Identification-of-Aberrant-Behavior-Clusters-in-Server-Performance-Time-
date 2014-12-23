--PIG script to parse out metrics from nmon log collection for one day
--Get collection file name from command line argument : pig -f nmon2file.pig -param input=collected_file save=file_delimiter

REGISTER /usr/lib/pig/piggybank.jar;

-- streaming routines for additional processing
DEFINE CMD `awk 'BEGIN{FS=",";} { for(N=5; N < NF/2; N+=1) { print \$1","\$2","\$4","\$3","\$N","\$(N+(NF/2))} }'` INPUT(stdin USING PigStreaming(',')) OUTPUT (stdout USING PigStreaming(','));

DEFINE AAA_CMD `awk '{for (i=0;i<4;i++) sub(",", "|", \$0); print}' | tr ',' '#' | tr '|' ','` INPUT(stdin USING PigStreaming(',')) OUTPUT (stdout USING PigStreaming(','));


--set pig.tmpfilecompression true;
--set pig.tmpfilecompression.codec lzo;
SET DEFAULT_PARALLEL 5;

raw_nmon_DS = LOAD '$input' using PigStorage(','); 
TimeStamp_raw = FILTER raw_nmon_DS BY $2=='ZZZZ' and $6 is null; 
TimeStamp = FOREACH TimeStamp_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray,$3 as Tvalue, ToUnixTime(ToDate(CONCAT(CONCAT($4,' '),$5),'H:mm:ss dd-MMM-yyyy','PST8PDT')) as Tunix:long, CONCAT(CONCAT($4,' '),$5) as Tdate:chararray;


--CPU_ALL
cpu_all_data_raw = filter raw_nmon_DS by $2=='CPU_ALL' and ($3 matches '^T[0-9].*');
cpu_all_data = foreach cpu_all_data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$3 as TS, $4 as User:float,$5 as Sys:float, $6 as Wait:float, $7 as Idle:float,($8 is NULL ? 0.0 : $8) as Busy:float,$9 as CPUs:int;
cpu_all_data_TS = join cpu_all_data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
cpu_all_data_TS = foreach cpu_all_data_TS generate cpu_all_data::fileName,metricName,Tdate,Tunix,User,Sys,Wait,Idle,Busy,CPUs,cpu_all_data::ymd;
rmf nmon_cpu_all_$save
STORE cpu_all_data_TS INTO 'nmon_cpu_all_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--AAA system config metrics
data_raw = filter raw_nmon_DS by $2=='AAA';

all_data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray,(chararray)$2 as metricName:chararray,$3 as option:chararray,$4.. as info:chararray;
DS = STREAM all_data THROUGH AAA_CMD as (fileName,ymd,metricName,option,info);
all_data2 = foreach DS generate fileName,metricName,option,info,ymd;
rmf nmon_AAA_$save
STORE all_data2 INTO 'nmon_AAA_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');


--BBBG,000,User Defined Disk Groups Name,Disks
data_raw = filter raw_nmon_DS by $2=='BBBG';
all_data = foreach data_raw generate (chararray)$0 as fileName:chararray,(chararray)$2 as metricName:chararray,$3 as diskNumber:chararray,$4 as diskGroup:chararray,$5 as diskName:chararray,$1 as ymd:chararray;
rmf nmon_BBBG_$save
STORE all_data INTO 'nmon_BBBG_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--MEM,Memory 
data_raw = filter raw_nmon_DS by $2=='MEM' and ($3 matches '^T[0-9].*');
data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$3 as TS, $4 as memtotal:float,$5 as hightotal:float,$6 as lowtotal:float,$7 as swaptotal:float,$8 as memfree:float,$9 as highfree:float,$10 as lowfree:float,$11 as swapfree:float,$12 as memshared:float,$13 as cached:float,$14 as active:float,$15 as bigfree:float,$16 as buffers:float,$17 as swapcached:float,$18 as inactive:float;
data_TS = join data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_TS = foreach data_TS generate data::fileName,metricName,Tdate,Tunix,memtotal,hightotal,lowtotal,swaptotal,memfree,highfree,lowfree,swapfree,memshared,cached,active,bigfree,buffers,swapcached,inactive,data::ymd;
rmf nmon_mem_$save
STORE data_TS INTO 'nmon_mem_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--PROC
data_raw = filter raw_nmon_DS by $2=='PROC' and ($3 matches '^T[0-9].*');
data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$3 as TS, $4 as Runnable:int,$5 as Blocked:int,$6 as pswitch:float,$7 as syscall:float,$8 as read:float,$9 as write:float,$10 as fork:float,$11 as exec:float,$12 as sem:float,$13 as msg:float;
data_TS = join data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_TS = foreach data_TS generate data::fileName,metricName,Tdate,Tunix,Runnable,Blocked,pswitch,syscall,read,write,fork,exec,sem,msg,data::ymd;
rmf nmon_proc_$save
STORE data_TS INTO 'nmon_proc_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--TOP
data_raw = filter raw_nmon_DS by $2=='TOP' and ($4 matches '^T[0-9].*');
data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$4 as TS, $3 as PID:long,$5 as CPU_pct:float,$6 as Usr_pct:float,$7 as Sys_pct:float,$8 as Size:long,$9 as ResSet:long,$10 as ResText:long,$11 as ResData:long,$12 as ShdLib:long,$13 as MinorFault:long,$14 as MajorFault:long,$15 as Command:chararray;
data_TS = join data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_TS = foreach data_TS generate data::fileName,metricName,Tdate,Tunix,PID,CPU_pct,Usr_pct,Sys_pct,Size,ResSet,ResText,ResData,ShdLib,MinorFault,MajorFault,Command,data::ymd;
rmf nmon_top_$save
STORE data_TS INTO 'nmon_top_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--UARG
data_raw = filter raw_nmon_DS by $2=='UARG' and ($3 matches '^T[0-9].*');
data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$3 as TS, $4 as PID:long,$5 as ProgName:chararray,$6 as FullCommand:chararray;
data_TS = join data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_TS = foreach data_TS generate data::fileName,metricName,Tdate,Tunix,PID,ProgName,FullCommand,data::ymd;
rmf nmon_uarg_$save
STORE data_TS INTO 'nmon_uarg_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--VM Memory,nr_dirty,nr_writeback,nr_unstable,nr_page_table_pages,nr_mapped,nr_slab,pgpgin,pgpgout,pswpin,pswpout,pgfree,pgactivate,pgdeactivate,pgfault,pgmajfault,pginodesteal,slabs_scanned,kswapd_steal,kswapd_inodesteal,pageoutrun,allocstall,pgrotated,pgalloc_high,pgalloc_normal,pgalloc_dma,pgrefill_high,pgrefill_normal,pgrefill_dma,pgsteal_high,pgsteal_normal,pgsteal_dma,pgscan_kswapd_high,pgscan_kswapd_normal,pgscan_kswapd_dma,pgscan_direct_high,pgscan_direct_normal,pgscan_direct_dma
data_raw = filter raw_nmon_DS by $2=='VM' and ($3 matches '^T[0-9].*');
data = foreach data_raw generate (chararray)$0 as fileName:chararray,$1 as ymd:chararray, (chararray)$2 as metricName:chararray,$3 as TS, $4 as nr_dirty:long,$5 as nr_writeback:long,$6 as nr_unstable:long,$7 as nr_page_table_pages:long,$8 as nr_mapped:long,$9 as nr_slab:long,$10 as pgpgin:long,$11 as pgpgout:long,$12 as pswpin:long,$13 as pswpout:long,$14 as pgfree:long,$15 as pgactivate:long,$16 as pgdeactivate:long,$17 as pgfault:long,$18 as pgmajfault:long,$19 as pginodesteal:long,$20 as slabs_scanned:long,$21 as kswapd_steal:long,$22 as kswapd_inodesteal:long,$23 as pageoutrun:long,$24 as allocstall:long,$25 as pgrotated:long,$26 as pgalloc_high:long,$27 as pgalloc_normal:long,$28 as pgalloc_dma:long,$29 as pgrefill_high:long,$30 as pgrefill_normal:long,$31 as pgrefill_dma:long,$32 as pgsteal_high:long,$33 as pgsteal_normal:long,$34 as pgsteal_dma:long,$35 as pgscan_kswapd_high:long,$36 as pgscan_kswapd_normal:long,$37 as pgscan_kswapd_dma:long,$38 as pgscan_direct_high:long,$39 as pgscan_direct_normal:long,$40 as pgscan_direct_dma:long;
data_TS = join data by (fileName,ymd,TS), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_TS = foreach data_TS generate data::fileName,metricName,Tdate,Tunix,nr_dirty,nr_writeback,nr_unstable,nr_page_table_pages,nr_mapped,nr_slab,pgpgin,pgpgout,pswpin,pswpout,pgfree,pgactivate,pgdeactivate,pgfault,pgmajfault,pginodesteal,slabs_scanned,kswapd_steal,kswapd_inodesteal,pageoutrun,allocstall,pgrotated,pgalloc_high,pgalloc_normal,pgalloc_dma,pgrefill_high,pgrefill_normal,pgrefill_dma,pgsteal_high,pgsteal_normal,pgsteal_dma,pgscan_kswapd_high,pgscan_kswapd_normal,pgscan_kswapd_dma,pgscan_direct_high,pgscan_direct_normal,pgscan_direct_dma,data::ymd;
rmf nmon_vm_$save
STORE data_TS INTO 'nmon_vm_$save' using org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');

--Instance metrics
dataHeader = filter raw_nmon_DS by ($2 matches 'NET.*' or $2 matches 'DISK.*' or $2 matches 'CPU[0-9].*' or $2 matches 'DG.*') and NOT($3 matches '^T[0-9].*');
data = filter raw_nmon_DS by ($2 matches 'NET.*' or $2 matches 'DISK.*'or $2 matches 'CPU[0-9].*' or $2 matches 'DG.*') and ($3 matches '^T[0-9].*');
DF = join data by ($0,$1,$2), dataHeader by ($0,$1,$2) USING 'replicated';
DS = STREAM DF THROUGH CMD as (machine,ymd,Tvalue,metric,value,instance);
DSF = FOREACH DS generate (chararray)$0 as machine:chararray,$1 as ymd:chararray,$2 as Tvalue, $3 as metric, $4 as value, $5 as instance;
data_TS = join DSF by (machine,ymd,Tvalue), TimeStamp by (fileName,ymd,Tvalue) USING 'replicated';
data_Final = FOREACH data_TS generate machine,metric,Tdate,Tunix,instance,value,DSF::ymd;
rmf nmon_instance_$save
STORE data_Final INTO 'nmon_instance_$save' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX');


