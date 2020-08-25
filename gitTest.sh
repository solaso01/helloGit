#!/bin/bash
TIME=`date -d "1 day ago" +%Y%m%d`
TIME_Dir=`date +%Y%m%d` 

TIMEHMS=`date +%Y%m%d_%H%M%S` 

DATABASE="db_dashboard"
TABLE_NAME="dim_marketing_fill_in_dimension_sku"
uuid=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "`
hive_table="stg_${DATABASE}_${TABLE_NAME}_dt"
hive_table=${hive_table//退款/refund}
sqlStr="select DATE_FORMAT(CURRENT_DATE(),'%Y%m%d') etl_date, \`id\`,\`sku_id\`,\`sku_name\`,\`type\`,\`valid\`,\`degree\`,\`create_time\`,\`update_time\`,\`subject_id\` from ${TABLE_NAME} t where 1=1   and \$CONDITIONS"
echo "$sqlStr"
sudo -u hdfs hive -e "drop table if exists stg.${hive_table};create table if not exists stg.stg_db_dashboard_dim_marketing_fill_in_dimension_sku_dt (etl_date string,\`id\`  int comment '主键Id' ,\`sku_id\`  int comment '课程sku' ,\`sku_name\`  string comment '课程名称' ,\`type\`  int comment '课程类型' ,\`valid\`  int comment '课程是否有效' ,\`degree\`  int comment '规则系数' ,\`create_time\`  bigint comment '' ,\`update_time\`  bigint comment '' ,\`subject_id\`  int comment 'subject_id' )ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001' STORED AS Parquet" 
sudo -u hdfs sqoop import -D mapreduce.job.queuename=etl.stg \
--options-file /home/service/sqoop/conf/db/import_db_db_dashboard.txt \
--hive-overwrite \
--hive-drop-import-delims -m 1 \
--hive-import \
--fields-terminated-by "\001" \
--lines-terminated-by "\n" \
--hive-database stg \
--hive-table $hive_table \
--query "$sqlStr" \
--null-string '\\N' \
--null-non-string '\\N' \
 \
--target-dir /data/hive/warehouse/stg.db/$uuid \
--as-parquetfile --delete-target-dir 
