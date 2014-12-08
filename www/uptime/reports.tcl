set_form_variables

# monitor_id

set db [ns_db gethandle]

set selection [ns_db 0or1row $db "select distinct *,to_char(first_monitored,'YYYY-MM-DD HH24:MI:SS') as started_monitor from uptime_urls where monitor_id = $monitor_id"]

if { $selection == "" } {
    # couldn't find the monitor
    ns_return $conn 200 text/html "couldn't find monitor $monitor_id"
    return
}

# we got a row back
set_variables_after_query

ReturnHeaders

ns_write $conn "<html>
<head>
<title>uptime reports for $url</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>$url</h2>

\[ <a href=\"urls-for-email.adp?email=[ns_urlencode $email]\">
all $email monitors 
</a>

|

your server: <a href=\"$homepage_url\">$homepage_url</a>

|

<a href=about.adp>About [uptime_system_name]</a>

\]


<hr>

Monitored since $started_monitor

<ul>
<li><a href=\"delete.tcl?monitor_id=$monitor_id\">
delete this monitor
</a> 

<li><a href=\"edit.tcl?monitor_id=$monitor_id\">
edit monitor parameters
</a>

</ul>

<h3>Events</h3>

(most recent first)

<ul>

"


set selection [ns_db select $db "select event_description,to_char(event_time,'YYYY-MM-DD HH24:MI:SS') as event_time
from uptime_log
where monitor_id = $monitor_id
order by event_time desc"]

set counter 0

while {[ns_db getrow $db $selection]} {
    set_variables_after_query
    incr counter
    ns_write $conn "<li>$event_time : $event_description\n"
}

if { $counter == 0 } {
    ns_write $conn "No incidents logged."
}

ns_write $conn "

</ul>

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

