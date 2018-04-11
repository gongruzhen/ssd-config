#! /usr/bin/tclsh

###########################################################################
#command format and option
###########################################################################
set template_name [lindex $argv 0]
set translate_format [lindex $argv 1]
if {$template_name == ""} {
    puts "plese use the formate \"hex2viewtool.tcl filename \[option\]\""
    puts "option:"
    puts "-v: default translate from hex to viewtool format"
    puts "-i: translate from hex to i2ctool format"
    puts "-w: translate from hex to Shannon SSD Nor Flash Write"
    puts "-r: translate from Shannon SSD Nor Flash Read to Nor Flash Write"
    puts "Example: ./hex2viewtool.tcl filename -w"
    puts ""
    puts "or please input the template file name : "
    puts "file name:"
    set template_name [gets stdin]
}
if {![file exists $template_name]} {
    puts "Template file \"$template_name\" doesn't exist!"
    exit
}
if {$translate_format != "" && $translate_format != "-v" && $translate_format != "-i" && $translate_format != "-w" && $translate_format != "-r"} {
    puts "plese use the formate \"hex2viewtool.tcl filename \[option\]\""
    puts "option:"
    puts "-v: default translate from hex to viewtool format"
    puts "-i: translate from hex to i2ctool format"
    puts "-w: translate from hex to Shannon SSD Nor Flash Write"
    puts "-r: translate from Shannon SSD Nor Flash Read to Nor Flash Write"
    puts "Example: ./hex2viewtool.tcl filename -w"
    puts ""
    exit
}

set result_name [format "%s.viewtool" $template_name]
set result_wrnor [format "%s.wrnor" $template_name]
set filer [open $template_name r]
puts "Open file \"$template_name\" to read"
set filer_lines [split [read $filer] \n]
set filew [open $result_name w]
set filew_wrnor [open $result_wrnor w]
puts "Open file \"$result_name\" to write"
puts "Open file \"$result_wrnor\" to write"
###########################################################################
#flag
###########################################################################
foreach lines $filer_lines {
    set line_vars [split $lines " "]
    if {[lindex $line_vars 0] == "_iloop_"} {
        set iloop_lsb [lindex $line_vars 1]
        set iloop_msb [lindex $line_vars 2]
    } elseif {[lindex $line_vars 0] == "_oloop_"} {
        set oloop_lsb [lindex $line_vars 1]
        set oloop_msb [lindex $line_vars 2]
    }
}
###########################################################################
#smbus write data at address
###########################################################################
# 0000000: 0401 0200 c000 0f9c 0000 0000 0000 0000  ................
#          A0A1 A2A3 D0D1 D2D3                      ................
# 0000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
# 0000020: 0a      

###############################
#viewtool format
###############################
set view_tool_pre "0|CH0|AA|00|写|8|"

###############################
#register address for nor pgm
###############################
set register_addressB0 0
set register_addressB1 0x10 # 0x10~0x14 4KB RAM for NOR
set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]

####################################################
#enter SMBus debug mode
####################################################
set address_data "ff ff 00 08 07 00 10 00"
puts $filew [format "%s%s|0|" $view_tool_pre $address_data]
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]
###############################
#read to check debug mode status
###############################



###############################
#unprotect nor flash
###############################
set address_data "00 04 00 1e 00 00 00 00"
#puts $filew [format "%s%s|0|" $view_tool_pre $address_data]
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]

###############################
#erase nor flash
###############################
set address_data "00 04 00 1d 00 00 00 00"
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]
set address_data "00 04 00 1d 00 00 00 80"
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]

####################################################
#get the write address and data
####################################################
set stop_flag 0
foreach lines $filer_lines {
  set line_vars [split $lines " "]
  set line_var0 [lindex  $line_vars 0]
  set line_var1 [lindex  $line_vars 1]
  set line_var2 [lindex  $line_vars 2]
  set line_var3 [lindex  $line_vars 3]
  set line_var4 [lindex  $line_vars 4]
  set line_var5 [lindex  $line_vars 5]
  set line_var6 [lindex  $line_vars 6]
  set line_var7 [lindex  $line_vars 7]
  set line_var8 [lindex  $line_vars 8]
  if {$line_var1 == "0000" && $line_var2 == "0000" && $line_var3 == "0000" && $line_var4 == "0000"} {
    set stop_flag 1
  }
####################################################
#process var1-4 to address_data1
####################################################
    set line_var1s [split  $line_var1 ""]
    set line_var10 [lindex  $line_var1s 0]
    set line_var11 [lindex  $line_var1s 1]
    set line_var12 [lindex  $line_var1s 2]
    set line_var13 [lindex  $line_var1s 3]
    set line_var2s [split  $line_var2 ""]
    set line_var20 [lindex  $line_var2s 0] 
    set line_var21 [lindex  $line_var2s 1] 
    set line_var22 [lindex  $line_var2s 2] 
    set line_var23 [lindex  $line_var2s 3] 
    set address_byte3 [format "%s%s" $line_var22 $line_var23]
    set address_byte2 [format "%s%s" $line_var20 $line_var21]
    set address_byte1 [format "%s%s" $line_var12 $line_var13]
    set address_byte0 [format "%s%s" $line_var10 $line_var11]
    set line_var3s [split  $line_var3 ""]
    set line_var30 [lindex  $line_var3s 0] 
    set line_var31 [lindex  $line_var3s 1] 
    set line_var32 [lindex  $line_var3s 2] 
    set line_var33 [lindex  $line_var3s 3] 
    set line_var4s [split  $line_var4 ""]
    set line_var40 [lindex  $line_var4s 0]    
    set line_var41 [lindex  $line_var4s 1]    
    set line_var42 [lindex  $line_var4s 2]    
    set line_var43 [lindex  $line_var4s 3]    
    set data_byte3 [format "%s%s" $line_var42 $line_var43]
    set data_byte2 [format "%s%s" $line_var40 $line_var41]
    set data_byte1 [format "%s%s" $line_var32 $line_var33]
    set data_byte0 [format "%s%s" $line_var30 $line_var31]
    set address [format "%s %s %s %s" $address_byte3 $address_byte2 $address_byte1 $address_byte0]
    set data [format "%s %s %s %s" $data_byte0 $data_byte1 $data_byte2 $data_byte3]
    set address_data [format "%s %s" $address $data]

###############################
#write to viewtool format file
###############################
  if {!$stop_flag} {
     puts $filew [format "%s%s|0|" $view_tool_pre $address_data]
  }

###############################
#write to registers for nor pgm by viewtool
###############################
  if {!$stop_flag} {
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $address]

     incr register_addressB0
     if {[expr $register_addressB0%256] == 0} {
       set register_addressB0 0x0
       incr register_addressB1
     }
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $data]
  }
 
####################################################
#process var5-8 to address_data2
####################################################
    set line_var1 $line_var5
    set line_var2 $line_var6
    set line_var3 $line_var7
    set line_var4 $line_var8
  if {$line_var1 == "0000" && $line_var2 == "0000" && $line_var3 == "0000" && $line_var4 == "0000"} {
    set stop_flag 1
  }

    set line_var1s [split  $line_var1 ""]
    set line_var10 [lindex  $line_var1s 0]
    set line_var11 [lindex  $line_var1s 1]
    set line_var12 [lindex  $line_var1s 2]
    set line_var13 [lindex  $line_var1s 3]
    set line_var2s [split  $line_var2 ""]
    set line_var20 [lindex  $line_var2s 0]
    set line_var21 [lindex  $line_var2s 1]
    set line_var22 [lindex  $line_var2s 2]
    set line_var23 [lindex  $line_var2s 3]
    set address_byte3 [format "%s%s" $line_var22 $line_var23]
    set address_byte2 [format "%s%s" $line_var20 $line_var21]
    set address_byte1 [format "%s%s" $line_var12 $line_var13]
    set address_byte0 [format "%s%s" $line_var10 $line_var11]
    set line_var3s [split  $line_var3 ""]
    set line_var30 [lindex  $line_var3s 0]
    set line_var31 [lindex  $line_var3s 1]
    set line_var32 [lindex  $line_var3s 2]
    set line_var33 [lindex  $line_var3s 3]
    set line_var4s [split  $line_var4 ""]
    set line_var40 [lindex  $line_var4s 0]
    set line_var41 [lindex  $line_var4s 1]
    set line_var42 [lindex  $line_var4s 2]
    set line_var43 [lindex  $line_var4s 3]
    set data_byte3 [format "%s%s" $line_var42 $line_var43]
    set data_byte2 [format "%s%s" $line_var40 $line_var41]
    set data_byte1 [format "%s%s" $line_var32 $line_var33]
    set data_byte0 [format "%s%s" $line_var30 $line_var31]
    set address [format "%s %s %s %s" $address_byte3 $address_byte2 $address_byte1 $address_byte0]
    set data [format "%s %s %s %s" $data_byte0 $data_byte1 $data_byte2 $data_byte3]
    set address_data [format "%s %s" $address $data]
###############################
#write to file
###############################
  if {!$stop_flag} {
     puts $filew [format "%s%s|0|" $view_tool_pre $address_data]
  }

###############################
#write to registers for nor pgm by viewtool
###############################
  if {!$stop_flag} {
     incr register_addressB0
     if {[expr $register_addressB0%256] == 0} {
       set register_addressB0 0x0
       incr register_addressB1
     }
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $address]

     incr register_addressB0
     if {[expr $register_addressB0%256] == 0} {
       set register_addressB0 0x0
       incr register_addressB1 
     }
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $data]
  }

}

###############################
#append 3 groups of 0 address/data
###############################
for {i=0;i<3;i=i+1} {
#for {set a 10}  {$a < 3} {incr a} #notice: less bracket
     set address "00 00 00 00"
     incr register_addressB0
     if {[expr $register_addressB0%256] == 0} {
       set register_addressB0 0x0
       incr register_addressB1
     }
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $address]

     set data "00 00 00 00"
     incr register_addressB0
     if {[expr $register_addressB0%256] == 0} {
       set register_addressB0 0x0
       incr register_addressB1
     }
     set register_address [format "00 04 %x %x" $register_addressB1 $register_addressB0]
     puts $filew_wrnor [format "%s%s %s|0|" $view_tool_pre $register_address $data]
}
###############################
#trigger nor flash pgm
###############################
set address_data "00 04 00 1d 00 00 00 00"
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]
set address_data "00 04 00 1d 00 00 00 40"
puts $filew_wrnor [format "%s%s|0|" $view_tool_pre $address_data]

close $filer
close $filew
puts "The file is OK!"
