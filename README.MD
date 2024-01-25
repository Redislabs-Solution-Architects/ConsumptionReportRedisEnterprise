# A humble utility script to generate a Consumption Report from Redis Enterprise Rest APIs


## Help

This script aims to get information from Redis Enterprise Cluster using its REST API and populate a CSV file for reporting purpose.


options:

-h     Print this Help.

-a     Hostname of the Redis Enterprise Cluster which link to its REST API. Default=locahost

-f     Filename which will host the reported data. Default=outputRedis.csv

-u     Username for the Redis Enterprise Cluster API. Default=admin@admin.com

-s     Password for the Redis Enterprise Cluster API. Default=admin


## Output 

db_uid	db_name	memory_limit	memory_used	replication	shards_count

db:27	database_27	10	0,01	TRUE	1