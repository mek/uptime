set dbs [ns_db gethandle main 3]
set sweep_db [lindex $dbs 0]
set db [lindex $dbs 1]
set db_sub [lindex $dbs 2]

set tsmask "YYYY-MM-DD HH24:MI:SS"

ns_db dml $db "delete from uptime_url_stats"

ReturnHeaders

ns_write "<html>
<head>
<title>Crunching Log Statistics</title>
</head>
<body bgcolor=white text=black>
<h2>Crunching Log Statistics</h2>
for Uptime
<hr>
<ul>
"

# for each url in uptime_urls, use the monitor with the earliest first_monitored
set sweep_selection [ns_db select $sweep_db "select url, min(monitor_id) as monitor_id, (sysdate() - min(first_monitored)) from uptime_urls uu where first_monitored = (select min(first_monitored) from uptime_urls where url = uu.url) group by url, first_monitored"]

while { [ns_db getrow $sweep_db $sweep_selection] } {
    set url [ns_set get $sweep_selection url]
    set monitor_id [ns_set get $sweep_selection monitor_id]
    ns_write "<li>$url\n"

    set selection [ns_db select $db "select to_char(event_time, '$tsmask') as event_time, event_description
 from uptime_log
 where monitor_id = $monitor_id
 order by event_time"]

    set total_real_incidents 0
    set last_down_time ""
    while { [ns_db getrow $db $selection] } {
        set_variables_after_query
        if { $event_description == "down" && $last_down_time == "" } {
            # site is down and we are not in a down state
            set last_down_time $event_time
        } 
        if { $event_description == "back_up" && $last_down_time != "" } {
            # we are back up after a down period, see if it is > 30 minutes
            set query "select (date_part('epoch',timestamp with time zone '$event_time' - '$last_down_time')) from dual"
            set last_down_time ""
            if { [database_to_tcl_string $db_sub $query] > 1800 } {
                incr total_real_incidents 
            }
        }
    }
    set n_days_monitored [database_to_tcl_string $db "select (date_part('day',sysdate() - min(first_monitored))) from uptime_urls where url = '[DoubleApos $url]'"]
    ns_db dml $db "insert into uptime_url_stats (url, n_days_monitored, n_outages) values ('[DoubleApos $url]', '$n_days_monitored', $total_real_incidents)"
}

ns_write "</ul>
done

</body></html>"
