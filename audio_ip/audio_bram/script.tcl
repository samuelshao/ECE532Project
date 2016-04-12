set fp [open "audio.txt" r]
#set fw [open "c_w.txt" "w"]
set address 0xC0000000
set val 0x4
set v [format %04X $address]
set error place1
puts $error

while {[ gets $fp line] > -1 } {
	set prefix 0x
	set prefix2 0x
	append prefix $v 
	#append prefix2 $line 
	mwr $prefix $line
	#set final mwr_func
	#append final " " $prefix " " $prefix2 "\n"
	#puts $final
	set address [ expr {$address + $val}]
	set v [format %04X $address]
}
close $fp
#close $fw

