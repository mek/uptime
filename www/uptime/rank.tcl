set db [ns_db gethandle]


ReturnHeaders 

ns_write  "<html>
<head>
<title>URLs ranked by incidents</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>URLs ranked by incidents</h2>

in <a href=\"/uptime/\">Uptime</a> 

<hr>

<ul>
"

# multiply outage rate by 1000 and divide it again afterwards
# to get around problem with fetching non-integer values w/ the Oracle
# driver
set selection [ns_db select $db "select url, n_days_monitored, (30 * n_outages / n_days_monitored * 1000) as outage_rate
from uptime_url_stats 
where n_days_monitored > 0
order by outage_rate, n_days_monitored DESC"]


while { [ns_db getrow $db $selection] } {
    set_variables_after_query
    set outage_rate [expr $outage_rate / 1000.0]
    ns_write  "<li><a href=\"statistics-for-one.tcl?url=[ns_urlencode $url]\">$url</a> ($outage_rate per month over $n_days_monitored days)\n"
}

ns_write  "

</ul>

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

