#!/bin/bash

set -x

/app/bin/aria2c -x4 --min-split-size=1M $url
