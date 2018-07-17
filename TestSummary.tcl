#! /usr/bin/tclsh

###########################################################################
#command format and option
###########################################################################


####################################################################################
#file I
####################################################################################
set result_name "FlashDataCollection.csv"
set filew [open $result_name w]
puts "Open file \"$result_name\" to write"
puts $filew ",,,,Bad Blocks,,,,tPROG(AVG)(us),,,,tPROG(MIN)(us),,,,tPROG(MAX)(us),,,,ECC-Max bit,,,,ECC-0(AVG)(Qty),,,,ECC-1-10,,,,ECC-11-20,,,,ECC-21-30,,,,ECC-31-40,,,"
puts $filew ",,,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,,CE0,,CE1,"
puts $filew "Product,Capacity,No.,UUID,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1,Plane0,Plane1"
###########################################################################
#file O
###########################################################################
exec ls -l > FileListTmp2
puts "HI"
set filer_tt [open FileListTmp r]
set filer_lines [split [read $filer_tt] \n]
set Start2ProcessDutCsv 0
puts $filer_lines
foreach lines_FileListTmp $filer_lines {
  set line_vars [split $lines_FileListTmp " "]
  set DutTestCsv [lindex $line_vars 8]
  if {[string match *DUT*.csv $DutTestCsv]} {
    set FileName $DutTestCsv
    set Start2ProcessDutCsv 1
  }
#start of one file to read
if {$Start2ProcessDutCsv} {
  puts "Open file \"$FileName\" to read"
  set filer [open $lines r]
#  set filer [open $lines_file_list r]
  set filer_lines [split [read $filer] \n]

################################################################
#process each nand target
################################################################
set line_counter 0
set Ce0Plane0Setup 0
set Ce0Plane1Setup 0
set Ce1Plane0Setup 0
set Ce1Plane1Setup 0
set Ce0Plane0BadBlock 0
set Ce0Plane1BadBlock 0
set Ce1Plane0BadBlock 0
set Ce1Plane1BadBlock 0
foreach lines $filer_lines {      #to read block info in file one by one
    set line_vars [split $lines ","]
  if {$line_counter==0} {
    if {[lindex $line_vars 0] == "BlockCount"} {
        set FileFormatOK 1
    } else {
        puts "The file \"$filer_lines\" format not exist:first word not BlockCount"
        exit
    }
  } elseif {$line_counter==1} {
        set BlockCount [lindex $line_vars 0]
        set EccDG0A [lindex $line_vars 2]
        set EccDG1A [lindex $line_vars 3]
        set EccDG2A [lindex $line_vars 4]
        set EccDG3A [lindex $line_vars 5]
        set EccDG4A [lindex $line_vars 6]
        set EccDG5A [lindex $line_vars 7]
        set EccDG6A [lindex $line_vars 8]
        set EccDG7A [lindex $line_vars 9]
        set EccDG8A [lindex $line_vars 10]
        set BlockType [lindex $line_vars 11]
        set tPROGA [lindex $line_vars 12]
        set CeIndex [lindex $line_vars 13]
        set PlaneIndex [lindex $line_vars 15]
        set UID [lindex $line_vars 16]
  }
  if {![$line_counter==0]} {
    set EccDG0 [lindex $line_vars 2]
    set EccDG1 [lindex $line_vars 3]
    set EccDG2 [lindex $line_vars 4]
    set EccDG3 [lindex $line_vars 5]
    set EccDG4 [lindex $line_vars 6]
    set EccDG5 [lindex $line_vars 7]
    set EccDG6 [lindex $line_vars 8]
    set EccDG7 [lindex $line_vars 9]
    set EccDG8 [lindex $line_vars 10]
    set BlockType [lindex $line_vars 11]
    set tPROG [lindex $line_vars 12]
    set CeIndex [lindex $line_vars 13]
    set PlaneIndex [lindex $line_vars 15]
    if {$CeIndex==0 && PlaneIndex==0} {
     if {$BlockType==0} {
      if {$Ce0Plane0Setup==0} {
        set EccDG0A00 [lindex $line_vars 2]
        set EccDG1A00 [lindex $line_vars 3]
        set EccDG2A00 [lindex $line_vars 4]
        set EccDG3A00 [lindex $line_vars 5]
        set EccDG4A00 [lindex $line_vars 6]
        set EccDG5A00 [lindex $line_vars 7]
        set EccDG6A00 [lindex $line_vars 8]
        set EccDG7A00 [lindex $line_vars 9]
        set EccDG8A00 [lindex $line_vars 10]
        set tPROGA00 [lindex $line_vars 12]
        set tPROGMin00 [lindex $line_vars 12]
        set tPROGMax00 [lindex $line_vars 12]
      } else {  #setup==1,not the first line
        set EccDG0A00 [expr [expr $EccDG0A00+$EccDG0]/2]
        set EccDG1A00 [expr [expr $EccDG1A00+$EccDG1]/2]
        set EccDG2A00 [expr [expr $EccDG2A00+$EccDG2]/2]
        set EccDG3A00 [expr [expr $EccDG3A00+$EccDG3]/2]
        set EccDG4A00 [expr [expr $EccDG4A00+$EccDG4]/2]
        set EccDG5A00 [expr [expr $EccDG5A00+$EccDG5]/2]
        set EccDG6A00 [expr [expr $EccDG6A00+$EccDG6]/2]
        set EccDG7A00 [expr [expr $EccDG7A00+$EccDG7]/2]
        set EccDG8A00 [expr [expr $EccDG8A00+$EccDG8]/2]
        set tPROGA00 [expr [expr $tPROGA00+$tPROG]/2]
        if {$tPROG < $tPROGMin00} {
            set $tPROGMin00 $tPROG
        }
        if {$tPROG > $tPROGMax00} {
            set $tPROGMax00 $tPROG
        } 
      }
      set Ce0Plane0Setup 1
     } else {
       incr $Ce0Plane0Badblock
     }
    }

    if {$CeIndex==0 && PlaneIndex==1} {
     if {$BlockType==0} {
      if {$Ce0Plane1Setup==0} {
        set EccDG0A01 [lindex $line_vars 2]
        set EccDG1A01 [lindex $line_vars 3]
        set EccDG2A01 [lindex $line_vars 4]
        set EccDG3A01 [lindex $line_vars 5]
        set EccDG4A01 [lindex $line_vars 6]
        set EccDG5A01 [lindex $line_vars 7]
        set EccDG6A01 [lindex $line_vars 8]
        set EccDG7A01 [lindex $line_vars 9]
        set EccDG8A01 [lindex $line_vars 10]
        set tPROGA01 [lindex $line_vars 12]
        set tPROGMin01 [lindex $line_vars 12] 
        set tPROGMax01 [lindex $line_vars 12] 
      } else {  #setup==1,not the first line
        set EccDG0A01 [expr [expr $EccDG0A01+$EccDG0]/2]
        set EccDG1A01 [expr [expr $EccDG1A01+$EccDG1]/2]
        set EccDG2A01 [expr [expr $EccDG2A01+$EccDG2]/2]
        set EccDG3A01 [expr [expr $EccDG3A01+$EccDG3]/2]
        set EccDG4A01 [expr [expr $EccDG4A01+$EccDG4]/2]
        set EccDG5A01 [expr [expr $EccDG5A01+$EccDG5]/2]
        set EccDG6A01 [expr [expr $EccDG6A01+$EccDG6]/2]
        set EccDG7A01 [expr [expr $EccDG7A01+$EccDG7]/2]
        set EccDG8A01 [expr [expr $EccDG8A01+$EccDG8]/2]
        if {$tPROG < $tPROGMin01} {
            set $tPROGMin01 $tPROG
        } 
        if {$tPROG > $tPROGMax01} {
            set $tPROGMax01 $tPROG
        }
      }
      set Ce0Plane1Setup 1
     } else {
       incr $Ce0Plane1Badblock
     }
    }

    if {$CeIndex==1 && PlaneIndex==0} {
     if {$BlockType==0} {
      if {$Ce1Plane0Setup==0} {
        set EccDG0A10 [lindex $line_vars 2]
        set EccDG1A10 [lindex $line_vars 3]
        set EccDG2A10 [lindex $line_vars 4]
        set EccDG3A10 [lindex $line_vars 5]
        set EccDG4A10 [lindex $line_vars 6]
        set EccDG5A10 [lindex $line_vars 7]
        set EccDG6A10 [lindex $line_vars 8]
        set EccDG7A10 [lindex $line_vars 9]
        set EccDG8A10 [lindex $line_vars 10]
        set tPROGA10 [lindex $line_vars 12]
        set tPROGMin10 [lindex $line_vars 12]
        set tPROGMax10 [lindex $line_vars 12]
      } else {  #setup==1,not the first line
        set EccDG0A10 [expr [expr $EccDG0A10+$EccDG0]/2]
        set EccDG1A10 [expr [expr $EccDG1A10+$EccDG1]/2]
        set EccDG2A10 [expr [expr $EccDG2A10+$EccDG2]/2]
        set EccDG3A10 [expr [expr $EccDG3A10+$EccDG3]/2]
        set EccDG4A10 [expr [expr $EccDG4A10+$EccDG4]/2]
        set EccDG5A10 [expr [expr $EccDG5A10+$EccDG5]/2]
        set EccDG6A10 [expr [expr $EccDG6A10+$EccDG6]/2]
        set EccDG7A10 [expr [expr $EccDG7A10+$EccDG7]/2]
        set EccDG8A10 [expr [expr $EccDG8A10+$EccDG8]/2]
        if {$tPROG < $tPROGMin10} {
            set $tPROGMin10 $tPROG
        }
        if {$tPROG > $tPROGMax10} {
            set $tPROGMax10 $tPROG
        }
      }
      set Ce1Plane0Setup 1
     } else {
       incr $Ce1Plane0Badblock
     }
    }

    if {$CeIndex==1 && PlaneIndex==1} {
     if {$BlockType==0} {
      if {$Ce1Plane1Setup==0} {
        set EccDG0A11 [lindex $line_vars 2]
        set EccDG1A11 [lindex $line_vars 3]
        set EccDG2A11 [lindex $line_vars 4]
        set EccDG3A11 [lindex $line_vars 5]
        set EccDG4A11 [lindex $line_vars 6]
        set EccDG5A11 [lindex $line_vars 7]
        set EccDG6A11 [lindex $line_vars 8]
        set EccDG7A11 [lindex $line_vars 9]
        set EccDG8A11 [lindex $line_vars 10]
        set tPROGA11 [lindex $line_vars 12]
        set tPROGMin11 [lindex $line_vars 12]
        set tPROGMax11 [lindex $line_vars 12]
      } else {  #setup==1,not the first line
        set EccDG0A11 [expr [expr $EccDG0A11+$EccDG0]/2]
        set EccDG1A11 [expr [expr $EccDG1A11+$EccDG1]/2]
        set EccDG2A11 [expr [expr $EccDG2A11+$EccDG2]/2]
        set EccDG3A11 [expr [expr $EccDG3A11+$EccDG3]/2]
        set EccDG4A11 [expr [expr $EccDG4A11+$EccDG4]/2]
        set EccDG5A11 [expr [expr $EccDG5A11+$EccDG5]/2]
        set EccDG6A11 [expr [expr $EccDG6A11+$EccDG6]/2]
        set EccDG7A11 [expr [expr $EccDG7A11+$EccDG7]/2]
        set EccDG8A11 [expr [expr $EccDG8A11+$EccDG8]/2]
        if {$tPROG < $tPROGMin11} {
            set $tPROGMin11 $tPROG
        }
        if {$tPROG > $tPROGMax11} {
            set $tPROGMax11 $tPROG
        }
      }
      set Ce1Plane1Setup 1
     } else {
       incr $Ce1Plane1Badblock
     }
    }



  }  #end of one file to read
set Start2ProcessDutCsv 0

  puts $filew "B16,64GB,$line_counter,$UID,$Ce0Plane0BakBlock,$Ce0Plane1BakBlock,$Ce1Plane0BakBlock,$Ce1Plane1BakBlock,tPROGA00,tPROGA01,tPROGA10,tPROGA11,tPROGMin00,tPROGMin01,tPROGMin10,tPROGMin11,tPROGMax00,tPROGMax01,tPROGMax10,tPROGMax11,,,,,EccDG0A00,EccDG0A01,EccDG0A10,EccDG0A11,EccDG1A00,EccDG1A01,EccDG1A10,EccDG1A11"
  close $filer
  set line_counter [expr $line_counter+1] 
  #incr $line_counter
}  #end of one file to write
}  #end all file to read and one file write


###########################################################################
#close file and exit process
###########################################################################
}  #end all file to read and one file write
close $filew
puts "The file is OK!"
