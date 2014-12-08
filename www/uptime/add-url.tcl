set_form_variables_string_trim_DoubleAposQQ
set_form_variables

# url, email, homepage_url, name, notification_mode, notification_interval_hours, password

set exception_text ""
set exception_count 0
set notificatoin_interval_hours 2

if { $url == "" || $url == "http://"} {

    append exception_text "<li>You didn't give us a URL to monitor.  This is required."
    incr exception_count
} else {  
    # url wasn't obviously bogus, check it 
    if [catch {set grabbed_text [ns_httpget $url]} errmsg] {
	# the GETURL failed
	set grabbed_text "actually it didn't return at all; perhaps the host name is
incorrect or the server is down?"
    }
    if { ![regexp -nocase "success" $grabbed_text] } {
	append exception_text "<li>We tried fetching $url but it did not return the string \"success\" as required by [uptime_system_name].  
Instead, it returned  
<blockquote><pre>
$grabbed_text
</pre></blockquote>
You may need to add a file to your Web server right now.  We don't want to
let you add this monitor before the file is there because otherwise you 
could get hammered with notifications forever.
"
        incr exception_count
    }
}

if { ![regexp {.+@.+\..+} $email] } {
    append exception_text "<li>The email address doesn't look right to us.  We need a full
Internet address, something like one of the following:

<code>
<ul>
<li>Joe.Smith@att.com
<li>1134565@beepers-r-us.com
<li>francois@unique.fr
</ul>
</code>
"
    incr exception_count

}

if { $homepage_url == "" || $homepage_url == "http://"} {

    append exception_text "<li>You didn't give us a homepage URL.  This is required because we use it to generate the reports user interface."
    incr exception_count
}

if { $password == "" } {

    append exception_text "<li>The password field was blank.  That means that anyone on the Internet
would be able to delete this monitor or view your uptime logs."
    incr exception_count
}

if { $name == "" } {
    append exception_text "<li>You forgot to enter your name.  We require this."
    incr exception_count
}

if { $exception_count != 0 } {

    # there was an error in the user input 
	
    if { $exception_count == 1 } {
	    
	set problem_string "a problem"
	set please_correct "it"
	    
    } else {
	    
	set problem_string "some problems"
	set please_correct "them"
	    
    }
	    
    ns_return $conn 200 text/html "<html>
	
    <head>
    <title>Problem adding URL</title>
    </head>
	
    <body bgcolor=#ffffff text=#000000>
	
    <h2>Problem adding URL</h2>
	
    <hr>
	
    We had $problem_string processing your entry:
	
    <ul> 
	
    $exception_text
	
    </ul>
	
    Please back up using your browser, correct $please_correct, and resubmit your entry.
	
    <p>
	
    Thank you.

    </body>
    </html>
	
    "

    return

}

# no obvious problems with the input

set db [ns_db gethandle]

set n_already [database_to_tcl_string $db "select count(*) from uptime_urls where url='$QQurl' and email = '$QQemail'"]

if { $n_already == 0 } {

   set monitor_id [database_to_tcl_string $db "select nextval('uptime_monitor_sequence') from dual"]
   set sql "insert into uptime_urls
(monitor_id, url, email, homepage_url, name, notification_mode, notification_interval_hours, password, first_monitored)
values
($monitor_id, '$QQurl','$QQemail', '$QQhomepage_url', '$QQname', '$QQnotification_mode', $QQnotification_interval_hours, '$QQpassword', sysdate())"
    ns_log notice "adding url $sql"
    if [catch { ns_db dml $db $sql } errmsg] {  
	ns_log Notice "error adding url: $errmsg"
	ns_return $conn 200 text/html "<html>
<head>
<title>Error updating database</title>
</head>
<body bgcolor=#ffffff text=#000000>
<h2>Error trying to update the database</h2>

<hr>

The problem could be that you typed something other than an integer
for notification interval.  If that's not it, then there might be a
problem with our software.  Here was the message:

<pre>

$errmsg

</pre>

</body>
</html>
" } else {

    ReturnHeaders
    ns_write $conn "<html>
<head>
<title>$url added</title>
</head>
<body bgcolor=#ffffff text=#000000>
<h2>$url added</h2>

to <a href=index.adp>[uptime_system_name]</a>

<hr>

[uptime_system_name] is now monitoring $url.  You may want to bookmark the
<a href=\"reports.tcl?monitor_id=$monitor_id\">
reports page
</a>.

<p>

Note: if $email is the address of a pager gateway, then you will probably want to 
go straight to 
<a href=\"edit-2.tcl?monitor_id=$monitor_id&password=[ns_urlencode $password]\">
the edit parameters page
</a> to add a custom subject line and/or a custom body.

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>

</body>
</html>

"

}

} else {

    # there already is a URL/email pair in the system

    ns_return $conn 200 text/html "<html>
<head>
<title>$url already being monitored</title>
</head>
<body bgcolor=#ffffff text=#000000>
<h2>$url already being monitored</h2>

by <a href=index.adp>[uptime_system_name]</a>

<hr>

If $url is down, email will be sent to $email.  That's pretty much
what you asked for just now....  

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>

</body>
</html>

"


}
