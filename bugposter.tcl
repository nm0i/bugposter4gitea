#!/usr/bin/tclsh

# Reads file specified in argv[0], posts first line as a title and the
# rest as a body.

# Requires to be run with pwd set as script location to read
# apikey.tcl.

package require tls
package require rest
package require json::write

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
switch $bugLabel {
    bug {
        set bugLabel 1
    }
    typo {
        set bugLabel 2
    }
    idea {
        set bugLabel 3
    }
    default {
        set bugLabel 1
    }
}
set bugBody ""
while {[gets $chan line] >= 0} {
    set bugBody [string cat "    " $bugBody "\n" $line]
}
close $chan

set headers [list "Authorization" "token $apiKey"]
set config [list method post format json headers $headers]

set query [list "body" $bugBody "title" $bugTitle "labels" [list $bugLabel]]

::http::register https 443 ::tls::socket
::rest::simple $hostURI $query $config
