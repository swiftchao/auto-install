FILE=ml2_conf_genericswitch.ini; LINE=$(grep -n -A 6 'genericswitch:7c1c-f1f3-6ca1' $FILE | grep -m1 password | awk -F '-' '{print $1}'); if [ -n "$LINE" ]; then sed -i "${LINE}s/.*/password = 666666/" $FILE; else echo "password = 333333" >> $FILE; fi