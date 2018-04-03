#! /usr/bin/tclsh

set template_name [lindex $argv 0]
if {$template_name == ""} {
    puts "please input the template file name : (or use the formate \"loop.tcl filename\")"
    set template_name [gets stdin]
}
if {![file exists $template_name]} {
    puts "Template file \"$template_name\" doesn't exist!"
    exit
}
set result_name [format "%s_result" $template_name]
set filer [open $template_name r]
puts "Open file \"$template_name\" to read"
set filer_lines [split [read $filer] \n]
set filew [open $result_name w]
puts "Open file \"$result_name\" to write"
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
for {set oloop $oloop_lsb} {$oloop<=$oloop_msb} {incr oloop 1} {
foreach lines $filer_lines {
  set line_vars [split $lines " "]
  set line_var0 [lindex  $line_vars 0]
  set line_var1 [lindex  $line_vars 1]
  if {$line_var0 != "_iloop_" && $line_var0 != "_oloop_"} {
    if {[string match *\^* $lines]} {
      set line_vars [split $lines \^]
      set num [llength $line_vars]
      for {set i 0} {$i<$num} {incr i 1} {
        set line_var$i [lindex $line_vars $i]
      }



      set lines $line_var0
      set lines [join $line_vars $oloop]











      }
      if {[string match *\%* $lines]} {
        set line_vars [split $lines \%]
      set num [llength $line_vars]
      for {set i 0} {$i<$num} {incr i 1} {
        set line_var$i [lindex $line_vars $i] 
      }   
for {set iloop $iloop_lsb} {$iloop<=$iloop_msb} {incr iloop 1} {
      set lines $line_var0
#      for {set i 1} {$i<$num} {incr i 1} {

        set lines [join $line_vars $iloop]








#       }
       puts $filew $lines
    }
  } else {
     puts $filew $lines
  }
 }
}
}
close $filer
close $filew
