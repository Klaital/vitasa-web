#!/bin/bash
DMINUS2=$(date --date='2 days ago' +"%Y-%m-%d")
DMINUS1=$(date --date='1 day ago' +"%Y-%m-%d")
echo "Current"
scp "vitasa@ps556589.dreamhostps.com:/home/vitasa/logs/vitasa.abandonedfactory.net/http/access.log" ./data/apache/
echo $DMINUS1
scp "vitasa@ps556589.dreamhostps.com:/home/vitasa/logs/vitasa.abandonedfactory.net/http/access.log.${DMINUS1}" ./data/apache/
echo $DMINUS2
scp "vitasa@ps556589.dreamhostps.com:/home/vitasa/logs/vitasa.abandonedfactory.net/http/access.log.${DMINUS2}" ./data/apache/
