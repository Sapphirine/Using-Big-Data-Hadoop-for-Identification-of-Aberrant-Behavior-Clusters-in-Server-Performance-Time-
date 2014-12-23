ADD FILE hwmapper.py; 
ADD FILE reduce_convert.R; 

set mapred.reduce.tasks=4;

use nmon_database; 

FROM (
   FROM ( select machine,MIN(idle) as mIdle,ymd from cpu_table group by ymd,machine ) id
   select transform(id.machine,id.mIdle,id.ymd) using 'hwmapper.py'
   as machine,abRatio
   cluster by machine) mo
select transform(mo.machine,mo.abRatio) USING 'reduce_convert.R'
as machine,abRatio;


