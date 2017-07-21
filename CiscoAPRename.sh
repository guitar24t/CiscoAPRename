#!/usr/bin/expect -f
# Robert Hilton (robert.a.hilton.jr@gmail.com)
# Argument 0 is the CSV file input. CSV Format is header row MAC,Serial,Room,Location,APName then the data following the header row
# Argument 1 is the IP address of the master controller
# Argument 2 is the username of the admin user
# Argument 3 is the password for the admin user
# Usage: ./CiscoAPRename.sh APs.csv 192.168.50.254 username password

package require csv
package require struct

::struct::matrix values

set file [lindex $argv 0 ]

set fid [open $file r]
::csv::read2matrix $fid values "," auto
close $fid
set maxRows [values rows]

set timeout -1
set ip [lindex $argv 1 ]
puts $ip
set usern [lindex $argv 2 ]
puts $usern
set pass [lindex $argv 3 ]
puts $pass


set currSec [clock seconds]
set currWeek [clock format $currSec -format %U]

spawn ssh wifisync@$ip

expect "*ser: "
send "$usern\r"

expect "*assword:"
send "$pass\r"

send "\r"
expect ">"
send "conf\r"
expect "config>"

for {set i 1} {$i<$maxRows} {incr i} {
	set macAddr [values get cell 0 $i]
	set serial [values get cell 1 $i]
	set roomNum [values get cell 2 $i]
	set location [values get cell 3 $i]
	set apName [values get cell 4 $i]
	set cmd "ap name $apName $macAddr"
    send "$cmd\r"
    expect "config>"
    set cmd "ap location '$location' $apName"
    send "$cmd\r"
    expect "config>"
    set cmd "ap group-name MHS $apName"
    send "$cmd\r"
    expect "(y/n) "
    send "y\r"
	expect "config>"
}

send "exit\r"
expect ">"
send "save config\r"
expect "(y/n) "
send "y\r"
expect ">"
send "logout\r"

