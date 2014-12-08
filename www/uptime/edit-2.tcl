set_the_usual_form_variables

# monitor_id, password

set db [ns_db gethandle]

set password_from_db [database_to_tcl_string $db "select password
from uptime_urls
where monitor_id = $monitor_id"]

if { [string compare [string trim [string toupper $password]] [string trim [string toupper $password_from_db]]] != 0 } {
    ns_returnredirect $conn "bad-password.tcl?monitor_id=$monitor_id"
    return
}

# if we got here, the password matched


set raw_form "<table>
<tr>
<th>Notification Mode
<td>
<input type=radio name=notification_mode value=\"down_then_up\"> Email when down then again when up
<input type=radio name=notification_mode value=\"periodic\"> Periodic

</tr>
<tr>
<th>
Notification Interval (hours)
<td>
<input type=text name=notification_interval_hours value=2>


<tr>
<th>Password

<td>
<input name=password type=text size=15>

<tr>
<th colspan=2 align=center>optional parameters
<tr><th>Custom Subject<td><input type=text name=custom_subject size=50>
<tr><th>Custom Body<td>
<textarea name=custom_body rows=6 cols=70>
</textarea>
</table>

"

set selection [ns_db 0or1row $db "select distinct * from uptime_urls where monitor_id = $monitor_id"]
set_variables_after_query

set stuffed_form [bt_mergepiece $raw_form $selection]

ns_return 200 text/html "<html>
<head>
<title>Edit Monitor for $url</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>Edit Monitor</h2>

for $url

<hr>

<form method=post action=edit-3.tcl>
<input type=hidden name=monitor_id value=\"$monitor_id\">
<input type=hidden name=old_password value=\"[philg_quote_double_quotes $password]\">

$stuffed_form

<center>
<input type=submit value=\"Update\">
</center>

</form>

Note: the optional parameters, if present, will cause [uptime_system_name] 
to send a custom email message to $email. This is only useful if $email is 
a pager gateway.

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

