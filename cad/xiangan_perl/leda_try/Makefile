RTL_DIR =/home/xiangan/tmp/leda_try/rtl/
RTL_TOP =i2cs_top
CHK_TYP =$(CHK_RTL)
####################################################
CHK_RTL =/home/xiangan/tmp/leda_try/rtl.tcl 
####################################################
leda:
    make clean
    make leda

clean:
    -rm -rf leda*
    -rm *.log
    -rm *.inf
    -rm *tmp*

leda:
    -leda -sverilog +v2k -full64 \
    -config $(CHK_TYP) \
    -f ./filelist \
    -bbox_file ./bbox_filelist \
    -clock_file ./clock_file \
    -top $(RTL_TOP) \
    -project leda \
    -nomaxmessages -nomaxviolations -nomaxtime\
    -translate_directive \
    -summary -full_log


 
