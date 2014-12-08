set_the_usual_form_variables

# monitor_id

set db [ns_db gethandle]
set selection [ns_db 1row $db "select * from uptime_urls where monitor_id = $monitor_id"]
set_variables_after_query

ns_return 200 text/html "<html>
<head>
<title>Bad Password</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Bad Password</h2>

for ($email, $url)

<hr>

The password that you entered was incorrect.  You can back up using
your browser and correct a typo, or

<a href=\"email-password.tcl?monitor_id=$monitor_id\">ask this server to email your password to $email</a>.


<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>
"
