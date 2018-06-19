#!/bin/bash

##Edit the DATE below to do a particular year/month/day. Keep the format as YYYY-MM-DD, you can use * as a wildcard. Example: 2018-02-*

DATE="*"
FILES="$FWDIR/log/$DATE.log"
swap_file1=swap1-$$
swap_file2=swap2-$$
report=$FILES-clean.csv

config="$FWDIR/conf/logexport.ini"
if [ -f "$config" ]
then
        printf "\nReplacing logexport.ini file\n"
        rm $FWDIR/conf/logexport.ini
        echo "[Fields_Info]" >> $FWDIR/conf/logexport.ini
        echo "included_fields = action,src,dst,proto,service,<REST_OF_FIELDS>" >> $FWDIR/conf/logexport.ini
else
        printf "\nCreating logexport.ini file\n"
        echo "[Fields_Info]" >> $FWDIR/conf/logexport.ini
        echo "included_fields = action,src,dst,proto,service,<REST_OF_FIELDS>" >> $FWDIR/conf/logexport.ini
fi

for f in $FILES
do
        printf "\nConverting Files $f\n"
        fwm logexport -n -p -i $f > $f.csv
        printf "\Cleaning up $f.csv"
        grep 'accept' $f.csv | awk -F\; '{print $3, $4, $5, $6 }' > $swap_file1
        sort -n $swap_file1 > $swap_file2
        uniq $swap_file2 > $f-clean.csv
        rm $swap_file1 $swap_file2 $f.csv
        FINAL=$(mv $f-clean.csv $PWD/)
done

cat *-clean.csv > swap1.csv
sort -n swap1.csv > swap2.csv
uniq swap2.csv >> final-connection-report.csv
rm swap* *-clean.csv
printf "\nUnique Connections file is final-connection-report.csv\n"
