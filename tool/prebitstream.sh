#!/bin/bash

if [ ! -e config ]; then
	echo "No config file"
	exit 1
fi

if echo $@ | grep -q -e "\-C" -e "\-\-chunk"; then
	echo "Not support dual plane read!"
	exit 1
fi

# read with ECC enable
sed -i 's/ecc_mode=.*/ecc_mode=0/' config

out=$(./ztool $@ -pME)

if [ $? -ne 0 ]; then
	printf "$out\n"
	exit 1
fi

printf "$out\n"

# read with ECC disable
sed -i 's/ecc_mode=.*/ecc_mode=1/' config

out=$(./ztool $@ -pEMD)

if [ $? -ne 0 ]; then
	printf "$out\n"
	exit 1
fi

printf "$out\n" > DISECCDATA

sed -i 's/ecc_mode=.*/ecc_mode=0/' config
