#!/bin/bash

set -x

len=$(curl -I $url | grep Content-Length | tr '\r' ' ' | awk '{print $2}')

echo ${len}

split=$(($len / 20))

echo ${split}
