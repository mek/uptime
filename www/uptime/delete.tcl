set_form_variables

# monitor_id

set db [ns_db gethandle]
set selection [ns_db 1row $db "select * from uptime_urls where monitor_id = $monitor_id"]
set_variables_after_query

ns_return $conn 200 text/html "<html>
<head>
<title>Stop monitoring $url</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Stop monitoring $url</h2>

<hr>

<form method=post action=delete-2.tcl>
<input type=hidden name=monitor_id value=\"$monitor_id\">
Password: <input type=password name=password size=15>
<p>
<input type=submit value=\"Yes, I'm sure that I want to delete this monitor\">
</form>

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

