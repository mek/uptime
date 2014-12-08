set_the_usual_form_variables
# url

set db [ns_db gethandle]

set tsmask "YYYY-MM-DD HH24:MI:SS"

set title "Statistics for $url"

ReturnHeaders

ns_write "[uptime_header $title]

from <a href=\"/uptime/\">Uptime</a>

<hr>
"

set selection [ns_db 0or1row $db "select n_days_monitored, n_outages from uptime_url_stats where url = '$QQurl'"]

set_variables_after_query


ns_write  "<ul>
<li>Number of periods of downtime longer than 25 minutes: $n_outages
<li>Number of days monitored: $n_days_monitored

"

if { $n_days_monitored != 0 } {
    ns_write  "<li>Outages per day:  [expr double($n_outages)/$n_days_monitored] ([expr 30*double($n_outages)/$n_days_monitored] per month)
"
}

ns_write  "</ul>
[uptime_footer]"

