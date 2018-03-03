#!/bin/bash

set -x

len=$(curl -I $url | grep Content-Length | tr '\r' ' ' | awk '{print $2}')

echo ${len}

split=$(($len / 20))

echo ${split}

range1=0
range2=$(($split - 1))

for ((i=0; i < 19; i++)); do
  echo $i $range1 $range2
  curl -r ${range1}-${range2} -o file.$i $url &
  range1=$(($range2 + 1))
  range2=$(($range2 + $split))
done

echo $range1
curl -r ${range1}-${len} -o file.19 $url &

wait

ls -lang
