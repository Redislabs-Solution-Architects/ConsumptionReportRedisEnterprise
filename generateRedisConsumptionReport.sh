Help()
{
   # Display Help
   echo "This script aims to get information from Redis Enterprise Cluster using its REST API and populate a CSV file for reporting purpose."
   echo
   echo "options:"
   echo "-h     Print this Help."
   echo "-a     Hostname of the Redis Enterprise Cluster which link to its REST API. Default=locahost"
   echo "-f     Filename which will host the reported data. Default=outputRedis.csv"
   echo "-u     Username for the Redis Enterprise Cluster API. Default=admin@admin.com"
   echo "-s     Password for the Redis Enterprise Cluster API. Default=admin"
   echo
}

while getopts a:f:u:s:h flag
do
    case "${flag}" in
        h) Help
              exit;;
        a) # Hostname of the API
          redis_cluster_api_url=${OPTARG};;
        f) # Filename of the output
          redis_filename=${OPTARG};;
        u) # username for API
          api_username=${OPTARG};;
        s) # Password for API
          api_password=${OPTARG};;
        \?) # Invalid option
         echo "Error: Invalid option"
         Help
         exit;;
    esac
done

#echo "$redis_cluster_api_url"
##Path config
#export PATH="/opt/redislabs/bin:$PATH"

#To make sure we deal with float with dots
#export LC_NUMERIC="en_US.UTF-8"
export LANG=C

#To make Inputs with

if [ -z $redis_cluster_api_url ]
  then
    echo "No arguments supplied for API hostname. Using default "
    redis_cluster_api_url="localhost"
fi

if [ -z $redis_filename ]
  then
    echo "No arguments supplied for Redis hostname. Using default."
    redis_filename="outputRedis.csv"
fi

if [ -z $api_username ]
  then
    echo "No arguments supplied for API Username. Using default. "
    api_username="admin@admin.com"
fi

if [ -z $api_password ]
  then
    echo "No arguments supplied for API Password. Using default. "
    api_password="admin"
fi

echo "db_uid,db_name,memory_limit,memory_used,replication,shards_count" > $redis_filename

# Json Parsing functions
parse_bdbs_json_objects() {
  local json_object=$1
  local memory_size=$(jq -r '.memory_size' <<< "${json_object}")
  local uid=$(jq -r '.uid' <<< "${json_object}")
  local db_name=$(jq -r '.name' <<< "${json_object}")
  local shards_count=$(jq -r '.shards_count' <<< "${json_object}")
  local replication=$(jq -r '.replication' <<< "${json_object}")
  local dbid="db:${uid}"
  local memory_size_gb=$(awk "BEGIN {print \"%.3f\", $memory_size/1024/1024/1024}")
  local bdbsstatsjson=$(curl -s -k -L -X GET -u "${api_username}:${api_password}" -H "Content-type:application/json" https://${redis_cluster_api_url}:9443/v1/bdbs/stats/last/$uid)
  local responsetoget=$(echo "${bdbsstatsjson}" | jq -c '.')
    while read -r rows; do
      local memory_used=$(jq -r '.used_memory' <<< "${rows}")
      local memory_used_gb=$(awk "BEGIN {printf \"%.3f\", $memory_used/1024/1024/1024}")
      echo "$dbid,$db_name,$memory_size_gb,$memory_used_gb,$replication,$shards_count" >> $redis_filename
    done <<< "$(echo "${responsetoget}" | jq -c '.[]')"
}

bdbsjson=$(curl -s -k -L -X GET -u "${api_username}:${api_password}" -H "Content-type:application/json" https://${redis_cluster_api_url}:9443/v1/bdbs)


  responsebdbs=$(echo "${bdbsjson}" | jq -c '.')
  while read -r row; do
    parse_bdbs_json_objects "${row}"
  done <<< "$(echo "${responsebdbs}" | jq -c '.[]')"
