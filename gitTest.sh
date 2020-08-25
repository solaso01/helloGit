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


curl  -H 'Content-Type: application/json' -XPUT 'http://192.1.6.74:9200/'dms_prpdcompany -d '{"settings":{"number_of_shards":6,"number_of_replicas":0},"mappings":{"properties":{"comcode":{"type":"keyword"},"comcname":{"type":"keyword"},"comename":{"type":"keyword"},"addresscname":{"type":"keyword"},"addressename":{"type":"keyword"},"postcode":{"type":"keyword"},"phonenumber":{"type":"keyword"},"taxnumber":{"type":"keyword"},"faxnumber":{"type":"keyword"},"uppercomcode":{"type":"keyword"},"insurername":{"type":"keyword"},"comattribute":{"type":"keyword"},"comtype":{"type":"keyword"},"comlevel":{"type":"keyword"},"manager":{"type":"keyword"},"accountleader":{"type":"keyword"},"cashier":{"type":"keyword"},"accountant":{"type":"keyword"},"remark":{"type":"keyword"},"newcomcode":{"type":"keyword"},"validstatus":{"type":"keyword"},"acntunit":{"type":"keyword"},"articlecode":{"type":"keyword"},"acccode":{"type":"keyword"},"centerflag":{"type":"keyword"},"outerpaycode":{"type":"keyword"},"innerpaycode":{"type":"keyword"},"flag":{"type":"keyword"},"webaddress":{"type":"keyword"},"servicephone":{"type":"keyword"},"attemperflag":{"type":"keyword"},"ipsegment":{"type":"keyword"},"usbkey":{"type":"keyword"},"cancelflag":{"type":"keyword"},"agentcode":{"type":"keyword"},"agreementno":{"type":"keyword"},"area_code":{"type":"keyword"},"begin_date":{"type":"keyword"},"branchtype":{"type":"keyword"},"combvisitrate":{"type":"keyword"},"comcodecirc":{"type":"keyword"},"comflag":{"type":"keyword"},"comkind":{"type":"keyword"},"comp_circ_code":{"type":"keyword"},"costcentercode":{"type":"keyword"},"dept_licence":{"type":"keyword"},"email":{"type":"keyword"},"end_date":{"type":"keyword"},"grouplevel":{"type":"keyword"},"groupnature":{"type":"keyword"},"groupnaturedetail":{"type":"keyword"},"invaliddate":{"type":"keyword"},"licenseno":{"type":"keyword"},"operatorcomcode":{"type":"keyword"},"pringpostcode":{"type":"keyword"},"printaddress":{"type":"keyword"},"printcomname":{"type":"keyword"},"remark1":{"type":"keyword"},"reportphone":{"type":"keyword"},"saleschannelcode":{"type":"keyword"},"sapcomcode":{"type":"keyword"},"sysareacode":{"type":"keyword"},"taxidenno":{"type":"keyword"},"updatedate":{"type":"keyword"},"updateflag":{"type":"keyword"},"upperclaimcomcode":{"type":"keyword"},"upperpath":{"type":"keyword"},"validdate":{"type":"keyword"},"businessnature":{"type":"keyword"},"visaswcomlevel":{"type":"keyword"},"comcodeforweb":{"type":"keyword"},"comsname":{"type":"keyword"}}}}'
