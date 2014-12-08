set_form_variables_string_trim_DoubleAposQQ
set_form_variables

# old_password, monitor_id are the hidden vars
# notification_mode, notification_interval_hours, custom_subject, custom_body, password
# are the form vars

set db [ns_db gethandle]

set password_from_db [database_to_tcl_string $db "select password
from uptime_urls
where monitor_id = $monitor_id"]

if { [string compare [string trim [string toupper $password]] [string trim [string toupper $password_from_db]]] != 0 } {
    ns_returnredirect $conn "bad-password.tcl?monitor_id=$monitor_id"
    return
}

# if we got here, the password matched

set exception_text ""
set exception_count 0

if { $password == "" } {

    append exception_text "<li>The password field was blank.  That means that anyone on the Internet
would be able to delete this monitor or view your uptime logs."
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
    <title>Problem editing monitor</title>
    </head>
	
    <body bgcolor=#ffffff text=#000000>
	
    <h2>Problem editing monitor</h2>
	
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

# no errors in user input

set sql "update uptime_urls
set notification_mode = '$QQnotification_mode',
notification_interval_hours = $notification_interval_hours,
custom_subject = '$QQcustom_subject',
custom_body = '$QQcustom_body',
password = '$QQpassword'
where monitor_id = $monitor_id"

    if [catch { ns_db dml $db $sql } errmsg] {  ns_return $conn 200 text/html "<html>
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

    set selection [ns_db 1row $db "select * from uptime_urls where monitor_id = $monitor_id"]
    set_variables_after_query
    ReturnHeaders
    ns_write $conn "<html>
<head>
<title>$url updated</title>
</head>
<body bgcolor=#ffffff text=#000000>
<h2>$url updated</h2>

in <a href=index.adp>[uptime_system_name]</a>

<hr>

Parameters updated:

<ul>
<li>Notification Mode: $notification_mode
<li>Notification Interval (hours): $notification_interval_hours
<li>Custom Subject: \"$custom_subject\"
<li>Custom Body: \"$custom_body\"

</ul>



You probably want to go back to the 
<a href=\"reports.tcl?monitor_id=$monitor_id\">
reports page
</a> now.

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>

</body>
</html>

"

} 
