#!/bin/bash
#JKABRRJ15HDA00331

psqloc=/Library/PostgreSQL/10/bin/
GUID=$((1 + RANDOM % 10000000000))

echo "Doing MMY conversion on VIN# "$1

curl -s https://www.cyclevin.com/vin-report/?vin=$1 | pup 'span[class="attribute-value"]' > tmp.txt

VIN=`cat tmp.txt | awk 'NR==2'`
YEAR=`cat tmp.txt | awk 'NR==5'`
MAKE=`cat tmp.txt | awk 'NR==8'`
MODEL=`cat tmp.txt | awk 'NR==11'`

echo "Inserting DB Record for VIN:"$VIN "Year:" $YEAR "Make:" $MAKE "Model:" $MODEL "With DB GUID of:" $GUID