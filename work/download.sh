#!/bin/bash

set -x

/app/bin/aria2c --max-connection-per-server=4 --min-split-size=1M $url
