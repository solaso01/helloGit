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




#集群的名称
cluster.name: es_one
#节点名称
node.name: node-1
#指定该节点是否有资格被选举成为master节点，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master
node.master: true
#允许该节点存储数据(默认开启)
node.data: true
#索引数据的存储路径
path.data: /home/software/elasticsearch-7.1.1/data
#日志文件的存储路径
path.logs: /home/software/elasticsearch-7.1.1/logs
#设置为true来锁住内存。因为内存交换到磁盘对服务器性能来说是致命的，当jvm开始swapping时es的效率会降低，所以要保证它不swap
bootstrap.memory_lock: false
#绑定的ip地址
network.host: 192.1.6.73
#设置对外服务的http端口，默认为9200
http.port: 9200
# 设置节点间交互的tcp端口,默认是9300
transport.tcp.port: 9300
#Elasticsearch将绑定到可用的环回地址，并将扫描端口9300到9305以尝试连接到运行在同一台服务器上的其他节点。
#这提供了自动集群体验，而无需进行任何配置。数组设置或逗号分隔的设置。每个值的形式应该是host:port或host
#（如果没有设置，port默认设置会transport.profiles.default.port 回落到transport.tcp.port）。
#请注意，IPv6主机必须放在括号内。默认为127.0.0.1, [::1]
##Elasticsearch7新增参数，写入候选主节点的设备地址，来开启服务时就可以被选为主节点,由discovery.zen.ping.unicast.hosts:参数改变而来
discovery.seed_hosts: ["192.1.6.73"]
#es7.x 之后新增的配置，初始化一个新的集群时需要此配置来选举master
cluster.initial_master_nodes: ["192.1.6.73"]
#SecComp检测，是：true、否：false
bootstrap.system_call_filter: false
#一次响应返回的分组的最大数据量
search.max_buckets : 100000000
#http请求的最大内容大小
http.max_content_length: 200mb
# 是否支持跨域，是：true，在使用head插件时需要此配置
http.cors.enabled: true
# “*” 表示支持所有域名
http.cors.allow-origin: "*"
