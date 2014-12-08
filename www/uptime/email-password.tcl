set_form_variables
set_form_variables_string_trim_DoubleAposQQ

# monitor_id 

set db [ns_db gethandle]

set selection [ns_db 1row $db "select distinct * from uptime_urls where monitor_id = $monitor_id"]
set_variables_after_query

if [catch {  ns_sendmail $email [uptime_system_owner] "Your [uptime_system_name] password" "Your [uptime_system_name] password is \"$password\" for 
\"$url\"

You can now visit 

[ns_conn location $conn]/uptime/reports.tcl?monitor_id=$monitor_id

to update your monitor.

" } errmsg] {
    # problem sending email, probably because address is way bad
    ns_return $conn 200 text/html "<html>
<head>
<title>Error Mailing Password</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Error Mailing Password</h2>

for $email

<hr>

We couldn't send your password to $email.  This could be because our
mail server is down right now, or, more likely, because \"$email\"
does not have the correct form of an Internet email address.

<P>

Here was the error message:
<blockquote><pre>
$errmsg
</pre></blockquote>

<hr>
<address>[uptime_system_owner]</address>
</body>
</html>
"
} else {
    # mail successful sent
    ns_return $conn 200 text/html "<html>
<head>
<title>Go and Read Your Mail</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Read Your Mail Now</h2>

<hr>

If you read your mail right now, you'll find a message from
[uptime_system_owner] with your password.

<p>

(Note: depending on where you are in the world, it could take a few
minutes for this mail to arrive.)

<hr>
<address>[uptime_system_owner]</address>
</body>
</html>
"
}
