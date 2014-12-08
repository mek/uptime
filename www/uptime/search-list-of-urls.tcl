set_form_variables 0

ReturnHeaders

ns_write "<html>
<head>
<title>URLs monitored by [uptime_system_name]</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>URLs monitored by [uptime_system_name]</h2>
<hr>

This is a list of all URLs monitored.  <a href=\"search-list-of-urls.tcl?stale_only_p=t\">Items marked \"stale\"</a> are
tested only once/day (to see if they have revived).  Non-stale URLs
are checked every 15 minutes.

<ul>

"

set db [ns_db gethandle]

if { [info exists stale_only_p] && $stale_only_p == "t" } {
    set query "select uu.*, uptime_stale_p(time_when_first_unreachable) as stale_p,to_char(time_when_first_unreachable,'YYYY-MM-DD HH24:MI:SS') as pretty_date
from uptime_urls uu
where uptime_stale_p(time_when_first_unreachable) = 't'
order by time_when_first_unreachable" 
} else {
    set query "select uu.*, uptime_stale_p(time_when_first_unreachable) as stale_p, to_char(time_when_first_unreachable,'YYYY-MM-DD HH24:MI:SS') as pretty_date
from uptime_urls uu
order by url"
}

set selection [ns_db select $db $query]

set total 0
set n_unreachable 0
set n_stale 0
while {[ns_db getrow $db $selection]} {
    set_variables_after_query
    incr total
    ns_write "<li><a href=\"reports.tcl?monitor_id=$monitor_id\">$url</a> (monitored for $name)\n"
    if { $time_when_first_unreachable != "" } {
	ns_write "<b>not reached since $pretty_date</b>\n"
    }
    if { $stale_p == "t" } {
	incr n_stale
	ns_write "<font color=red>(stale)</font>\n"
    }
    if { $time_when_first_unreachable != "" } {
	incr n_unreachable
    }
}

ns_write "

</ul>

"

if { ![info exists stale_only_p] || $stale_only_p != "t" } {
    ns_write "$total URLs monitored; $n_unreachable are current marked unreachable,
of which $n_stale are considered stale.  In other words, 
[expr round((($n_unreachable - double($n_stale))/($total - $n_stale))*100)]%
of the actively monitored URLs are unreachable.
"
}

ns_write "

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>
</body>
</html>"

