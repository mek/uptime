set_form_variables

# monitor_id

ns_return $conn 200 text/html "<html>
<head>
<title>Edit Monitor $monitor_id</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Edit Monitor $monitor_id</h2>

<hr>

<form method=post action=edit-2.tcl>
<input type=hidden name=monitor_id value=\"$monitor_id\">
Password: <input type=password name=password size=15>
<p>
<input type=submit value=\"Edit this monitor\">
</form>

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

