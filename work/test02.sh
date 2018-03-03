#!/bin/bash

set -x

count=${1}

len=$(curl -I $url | grep Content-Length | tr '\r' ' ' | awk '{print $2}')

echo ${len}

split=$(($len / ${count}))

echo ${split}

range1=0
range2=$(($split - 1))

loop_end=$(($count - 1))

for ((i=0; i < ${loop_end}; i++)); do
  suffix=$(printf "%03d" $i)
  echo $i $suffix $range1 $range2
  curl -r ${range1}-${range2} -o file.$suffix $url &
  range1=$(($range2 + 1))
  range2=$(($range2 + $split))
done

echo $range1
curl -r ${range1}-${len} -o file.${loop_end} $url &

wait

cat file.* > /tmp/filedata.dat

base64 -w 0 /tmp/filedata.dat > /tmp/filedata.dat.base64.txt

ls -lang

# ***** postgresql *****

postgres_user=$(echo ${DATABASE_URL} | awk -F':' '{print $2}' | sed -e 's/\///g')
postgres_password=$(echo ${DATABASE_URL} | grep -o '/.\+@' | grep -o ':.\+' | sed -e 's/://' | sed -e 's/@//')
postgres_server=$(echo ${DATABASE_URL} | awk -F'@' '{print $2}' | awk -F':' '{print $1}')
postgres_dbname=$(echo ${DATABASE_URL} | awk -F'/' '{print $NF}')

export PGPASSWORD=${postgres_password}

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
DELETE
  FROM t_files
 WHERE file_name = 'filedata.dat'
__HEREDOC__

set +x
base64_text=$(cat /tmp/filedata.dat.base64.txt)

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
INSERT INTO t_files (file_name, file_base64_text) VALUES ('filedata.dat', '${base64_text}');
__HEREDOC__
set -x
