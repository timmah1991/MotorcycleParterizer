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
TRIM=`cat tmp.txt | awk 'NR==14'`
COO=`cat tmp.txt | awk 'NR==17'`
STYLE=`cat tmp.txt | awk 'NR==20'`
ENGINE=`cat tmp.txt | awk 'NR==23'`
rm tmp.txt

echo "Inserting DB Record for VIN:"$VIN "Year:" $YEAR "Make:" $MAKE "Model:" $MODEL "Trim:" $TRIM "Country Origin:" $COO "Style:" $STYLE "Engine:" $ENGINE "With DB GUID of:" $GUID

#TODO: turn the above statement into an insert command in Postgres

#TODO: Turn MMY into top level parts fiche list EG: https://www.partsfish.com/oemparts/l/kaw/57f51f0d87a8660d6c7c9797/2017-z125-pro-br125jhf-parts
TLPF='https://www.partsfish.com/oemparts/l/kaw/57f51f0d87a8660d6c7c9797/2017-z125-pro-br125jhf-parts' #setting TLPF statically for now
#TLFP=`https://www.partsfish.com/oemparts/l/yam/500418c7f8700209bc78516a/1975-dt250b-parts` #setting to skylers bike



for i in `curl -s $TLPF | pup 'ul[class="partsubselect"]' | grep href | sed 's/^[^\/]*/https\:\/\/www.partsfish.com/' | sed 's/\">//'`; do
            echo "Calculating part numbers from the following URL" $i
            for n in `curl -s $i | pup 'span[class="itemnum"]' | grep "^\s"`; do
                        #echo "Checking eBay listing for sales of the following part#" $n
                        curl -s https://www.ebay.com/sch/i.html?_from=R40\&_nkw=$n\&_sacat=0\&LH_Complete=1\&LH_Sold=1\&_sop=16 > $n.html
                        if cat $n.html | grep -q "0 results"; then
                            echo "no sales found for part number" $n
                        else
                            echo "The following sale prices were found for" $n
                            echo "use the following URL to access the results list https://www.ebay.com/sch/i.html?_from=R40&_nkw="$n"&_sacat=0&LH_Complete=1&LH_Sold=1&_sop=16" 
                            echo "use the following link to see sold listings for" $n " https://www.ebay.com/sch/i.html?_from=R40&_nkw="$n"&_sacat=0&LH_Complete=1&LH_Sold=1&_sop=16" >> soldindex.txt
                            cat $n.html | pup 'span[class="POSITIVE"]' | grep "^\s"
                        fi
                        rm $n.html
                    done
        done

cat soldindex.txt
rm soldindex.txt

#Take the top level parts fiche and turn it into a list of subfiche links
#curl $TLPF | pup 'ul[class="partsubselect"]' | grep href | sed 's/^[^\/]*/https\:\/\/www.partsfish.com/' | sed 's/\">//'
#EG: curl https://www.partsfish.com/oemparts/l/kaw/57f51f0d87a8660d6c7c9797/2017-z125-pro-br125jhf-parts | pup 'ul[class="partsubselect"]' | grep href | sed 's/^[^\/]*/https\:\/\/www.partsfish.com/' | sed 's/\">//'



#Take the subfiche link, curl it, return the part numbers
#curl $i| pup 'span[class="itemnum"]' | grep "^\s"
#EG: curl https://www.partsfish.com/oemparts/a/kaw/57f51f1287a8660d6c7c979a/air-cleaner | pup 'span[class="itemnum"]' | grep "^\s" 



#Look up recent sales prices of the part #
#curl https://www.ebay.com/sch/i.html?_from=R40\&_nkw=$PARTNUMBER\&_sacat=0\&LH_Complete=1\&LH_Sold=1\&_sop=16 | pup 'span[class="POSITIVE"]' | grep "^\s" 
#EG: curl https://www.ebay.com/sch/i.html?_from=R40\&_nkw=49070-0812\&_sacat=0\&LH_Complete=1\&LH_Sold=1\&_sop=16 | pup 'span[class="POSITIVE"]' | grep "^\s"
