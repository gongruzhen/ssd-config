#! /bin/bash
channel_count=8
delay_value=$1
for ((channel=0; channel<$channel_count; channel++)) 
do	
	let reg_addr=136+channel*2+1;
	reg_addr_hex=$(printf %x $reg_addr)
	reg_value=$(./ztool utils peek-regs $reg_addr_hex 1);
	printf "\t$reg_value";
done
printf "\n";
for ((channel=0; channel<$channel_count; channel++)) 
do
	let reg_addr=136+channel*2+1;
	let value=delay_value*2;
	reg_addr_hex=$(printf %x $reg_addr);
	value_hex=$(printf %x $value);
	printf "\t$reg_addr_hex:$value_hex";
	./ztool utils poke-regs $reg_addr_hex $value_hex;
done
printf "\n"
