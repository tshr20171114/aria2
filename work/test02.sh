#!/bin/bash

set -x

len=$(curl -I $url | grep Content-Length | tr '\r' ' ' | awk '{print $2}')

echo ${len}

split=$(($len / 50))

echo ${split}

range1=0
range2=$(($split - 1))

for ((i=0; i < 49; i++)); do
  suffix=$(printf "%02d" $i)
  echo $i $suffix $range1 $range2
  curl -r ${range1}-${range2} -o file.$suffix $url &
  range1=$(($range2 + 1))
  range2=$(($range2 + $split))
done

echo $range1
curl -r ${range1}-${len} -o file.49 $url &

wait

cat file.* filedata.dat

ls -lang
