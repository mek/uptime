ns_log notice "config.tcl: starting to read uptime server config file..."

set httpport               80
set httpsport              443

# The hostname and address should be set to actual values.
set hostname               [ns_info hostname]
set address                [ns_info address]

set servername             "uptime"
set serverdesc             "Postrges Uptime Server"
set server		   $servername

set homedir                 "/usr/local/aolserver"
set bindir                  "/usr/local/aolserver/bin"

set pageroot               /web/${servername}/www
set directoryfile          index.adp,index.html,index.htm,index.tcl

set ext [info sharedlibextension]

# nsssl: Only loads if keyfile.pem and certfile.pem exist.
set sslmodule              nsssl${ext}  ;# Domestic 128-bit/1024-bit SSL.
set sslmodule              nsssle${ext} ;# Exportable 40-bit/512-bit SSL.
set sslkeyfile   ${homedir}/servers/${servername}/modules/nsssl/keyfile.pem
set sslcertfile  ${homedir}/servers/${servername}/modules/nsssl/certfile.pem

# nscp: Uncomment the sample password and log in with "nsadmin", password "x",
#       type "ns_crypt newpassword salt" and put the encrypted string below.
set nscp_port 9001
set nscp_addr 127.0.0.1
#set nscp_user ""
set nscp_user "nsadmin:t2GqvvaiIUbF2:" ;# sample user="nsadmin", pw="x".


#
# Global server parameters
#
ns_section "ns/parameters"
ns_param   home            $homedir
ns_param   debug           false
ns_param   ServerLog       /web/${server}/logs/server.log
ns_param   LogRoll	   on
ns_param   LogMaxBackup    30
ns_param   PidFile         /web/${server}/nspid.${server}
#
# Thread library (nsthread) parameters
#
ns_section ns/threads
ns_param   mutexmeter         true      ;# measure lock contention
ns_param   stacksize          500000

#
# MIME types.
#
#  Note: AOLserver already has an exhaustive list of MIME types, but in
#  case something is missing you can add it here.
#
ns_section "ns/mimetypes"
ns_param   default         "*/*"     ;# MIME type for unknown extension.
ns_param   noextension     "*/*"     ;# MIME type for missing extension.
#ns_param   ".xls"          "application/vnd.ms-excel"


############################################################
#
# Server-level configuration
#
#  There is only one server in AOLserver, but this is helpful when multiple
#  servers share the same configuration file.  This file assumes that only
#  one server is in use so it is set at the top in the "server" Tcl variable.
#  Other host-specific values are set up above as Tcl variables, too.
#

ns_section "ns/servers"
ns_param   $servername     $serverdesc


#
# Server parameters
#
ns_section "ns/server/${servername}"
ns_param   directoryfile   $directoryfile
ns_param   pageroot        $pageroot
ns_param   globalstats     true      ;# Enable built-in statistics.
ns_param   urlstats        true      ;# Enable URL statistics.
ns_param   maxurlstats     1000      ;# Max number of URL's to do stats on.
ns_param   enabletclpages  true 	;# Parse *.tcl files in pageroot.
ns_param   maxconnections     75
ns_param   maxdropped         0
ns_param   maxthreads         50
ns_param   minthreads         25
ns_param   threadtimeout      120

# Directory listings -- use an ADP or a Tcl proc to generate them.
#ns_param   directoryadp    $pageroot/dirlist.adp ;# Choose one or the other.
ns_param   directoryproc   _ns_dirlist           ;#  ...but not both!
ns_param   directorylisting fancy ;# Can be simple or fancy.

#
# ADP (AOLserver Dynamic Page) configuration
#
ns_section "ns/server/${servername}/adp"
ns_param   map             "/*.adp"  ;# Extensions to parse as ADP's.
ns_param   map             "/*.html" ;# Any extension can be mapped.
ns_param   enableexpire    false     ;# Set "Expires: now" on all ADP's.
ns_param   enabledebug     false     ;# Allow Tclpro debugging with "?debug".

# ADP special pages
#ns_param   errorpage      ${pageroot}/errorpage.adp ;# ADP error page.


#
# ADP custom parsers -- see adp.c
#
ns_section "ns/server/${servername}/adp/parsers"
ns_param   adp             ".adp"    ;# adp is the default parser.

ns_section "ns/server/${server}/tcl"
        ns_param autoclose      "on"
        ns_param debug          "false"
        ns_param library 	"/web/${server}/tcl"


#
# Socket driver module (HTTP)  -- nssock
#
ns_section "ns/server/${servername}/module/nssock"
ns_param   port            $httpport
ns_param   hostname        $hostname
ns_param   address         $address
ns_param   timeout	   120

#
# Socket driver module (HTTPS) -- nsssl
#
#  nsssl does not load unless sslkeyfile/sslcertfile exist (above).
#
ns_section "ns/server/${servername}/module/nsssl"
ns_param   port            $httpsport
ns_param   hostname        $hostname
ns_param   address         $address
ns_param   keyfile         $sslkeyfile
ns_param   certfile        $sslcertfile


#
# Control port -- nscp
#
#  nscp does not load unless nscp_user is a valid user.
#
ns_section "ns/server/${servername}/module/nscp"
ns_param   port            $nscp_port
ns_param   address         $nscp_addr

#ns_section "ns/server/${servername}/module/nscp/users"
#ns_param   user            $nscp_user


#
# Access log -- nslog
#
ns_section "ns/server/${servername}/module/nslog"
ns_param   file            /web/${servername}/logs/${servername}.log
ns_param   rolllog         true      ;# Should we roll log?
ns_param   rollonsignal    true      ;# Roll log on SIGHUP.
ns_param   rollhour        0         ;# Time to roll log.
ns_param   rollfmt	   %Y-%m-%d-%H
#ns_param   maxbackup       5         ;# Max number to keep around when rolling.


#
# CGI interface -- nscgi
#
#  WARNING: These directories must not live under pageroot.
#
ns_section "ns/server/${servername}/module/nscgi"
#ns_param   map "GET  /cgi /web/${server}/cgi"     ;# CGI script file dir (GET).
#ns_param   map "POST /cgi /web/${server}/cgi"     ;# CGI script file dir (POST).

#ns_section "ns/server/${servername}/module/nsperm"
#ns_param   skiplocks off

ns_section "ns/db/drivers"
    ns_param   postgres     ${bindir}/postgres.so  

ns_section "ns/db/pools"
    ns_param   main       "Uptime Main Pool"

ns_section "ns/db/pool/main"
    ns_param Driver postgres
    ns_param Connections 50
    ns_param DataSource localhost::uptime
    ns_param User nsadmin                   
    ns_param Password "ch0ch0"
    ns_param Verbose Off                    
    ns_param LogSQLErrors On
    ns_param ExtendedTableInfo On
    #ns_param MaxOpen 1000000000            
    #ns_param MaxIdle 1000000000            

ns_section "ns/server/${server}/db"
        ns_param Pools          "*"
        ns_param DefaultPool    "main"

#
# Modules to load
#
ns_section "ns/server/${servername}/modules"
ns_param   nssock          ${bindir}/nssock${ext}
ns_param   nslog           ${bindir}/nslog${ext}
#ns_param   nscgi           ${bindir}/nscgi${ext}  ;# Map the paths before using.
#ns_param   nsperm          ${bindir}/nsperm${ext} ;# Edit passwd before using.


#
# nsssl: Only loads if sslcertfile and sslkeyfile exist (see above).
#
if { [file exists $sslcertfile] && [file exists $sslkeyfile] } {
    ns_param nsssl ${bindir}/${sslmodule}
} else {
    ns_log warning "config.tcl: nsssl not loaded -- key/cert files do not exist."
}

#
# nscp: Only loads if nscp_user is set (see above).
#
if { $nscp_user != "" } {

    if ![string match "127.0.0.1" $nscp_addr] {
	# Anything but 127.0.0.1 is not recommended.
	ns_log warning "config.tcl: nscp listening on ${nscp_addr}:${nscp_port}"
    }
    ns_param nscp ${bindir}/nscp${ext}

} else {
    ns_log warning "config.tcl: nscp not loaded -- user/password is not set."
}

ns_log notice "config.tcl: finished reading uptime server config file."
