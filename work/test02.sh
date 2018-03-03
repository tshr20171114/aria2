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

cat file.* > filedata.dat

base64 -w 0 filedata.dat filedata.dat.base64.txt

ls -lang
