#!/usr/bin/tclsh

# Reads file specified in argv[0], posts first line as a title and the
# rest as a body.

# Requires to be run with pwd set as script location to read
# apikey.tcl.

package require http
package require tls

#set apiKey
#set hostUri
source apikey.tcl

set fName [lindex $argv 0]
if {! [file exists $fName]} {
    puts "No such file: $fName"
    exit
}

set chan [open $fName]
gets $chan line
set bugTitle $line
gets $chan line
set bugLabel $line
set bugBody ""
while {[gets $chan line] >= 0} {
    set bugBody [string cat "    " $bugBody "\n" $line]
}
close $chan

http::register https 443 tls::socket

set query [::http::formatQuery "body" $bugBody "title" [string cat $bugLabel ": " $bugTitle] ]

set httpToken [::http::config -urlencoding utf-8]
set httpToken [::http::geturl "$hostURI" -headers [list "Authorization" "token $apiKey"] -query $query]

::http::cleanup $httpToken
