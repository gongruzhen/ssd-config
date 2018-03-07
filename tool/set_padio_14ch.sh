#! /bin/bash
channel_count=14
delay_value=$1
for ((channel=0; channel<$channel_count; channel++)) 
do	
	let reg_addr=136+channel*4;
	reg_addr_hex=$(printf %x $reg_addr)
	reg_value=$(./ztool utils peek-regs $reg_addr_hex 1);
	printf "\t$reg_value";
done
printf "\n";
for ((channel=0; channel<$channel_count; channel++)) 
do
	let reg_addr=136+channel*4;
#let value=delay_value;
#let value="03450a10";
	reg_addr_hex=$(printf %x $reg_addr);
#value_hex=$(printf %x $value);
        value_hex="03450a10";
	printf "\t$reg_addr_hex:$value_hex";
	./ztool utils poke-regs $reg_addr_hex $value_hex;
done
printf "\n"
