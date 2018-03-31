#!/bin/bash

set -x

count=40

len=$(curl -I $url | grep Content-Length | tr '\r' ' ' | awk '{print $2}')

echo ${len}

split=$(($len / ${count}))

echo ${split}

range1=0
range2=$(($split - 1))

loop_end=$(($count - 1))

tmp_dir=$(date "+%Y%m%d%H%M%S")

mkdir 666 /tmp/${tmp_dir}

for ((i=0; i < ${loop_end}; i++)); do
  suffix=$(printf "%02d" $i)
  echo $i $suffix $range1 $range2
  curl --retry 10 -r ${range1}-${range2} -o /tmp/${tmp_dir}/file.$suffix $url &
  range1=$(($range2 + 1))
  range2=$(($range2 + $split))
done

echo $range1
curl -r ${range1}-${len} -o /tmp/${tmp_dir}/file.${loop_end} $url &

wait

cat /tmp/${tmp_dir}/file.* > /tmp/filedata.dat
