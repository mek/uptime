# uptime-defs.tcl, bashed for Oracle by philg@mit.edu on 4/30/98

# after how many days of unreachability is a monitor
# considered stale (and only needs to be checked once/day)

# this is actually encapsulated in a PL/SQL proc now that we're on Oracle
proc uptime_stale_days {} {
    return "10"
}

proc uptime_system_name {} {
    return "Uptime"
}

proc uptime_system_owner {} {
    return "SYSTEMOWNER"
}

proc uptime_system_timezone {} {
    return "Eastern Time (New York)"
}

proc uptime_url_base {} {
    return "BASEURL"
}

proc uptime_footer {} {
    return "<hr>\n<a href=\"mailto:[uptime_system_owner]\">[uptime_system_owner]
</a>\n</body>\n</html>"
}

proc uptime_header { {title ""} } {
    return "<html><head>\n
<title>$title</title>\n
</head>\n
<link rel=stylesheet type=\"text/css\" href=\"/uptime.css\">\n
<body>
<h2>$title</h2>
<hr>"
}

proc uptime_gateway {} {
    # set this to your gateway to test :)
    return "www.yahoo.com"
}

proc uptime_gateway_reachable_p { gateway } {
    if [catch {set pingoutput [exec ping -n -c 1 $gateway]}] {
	return 0
    } else {
	return 1
    }
}

proc uptime_monitor_list_of_ids {db monitor_ids} {

    if {![uptime_gateway_reachable_p [uptime_gateway]]} {
	ns_log Notice "can not reach [uptime_gateway]"
	return
    } 

    foreach monitor_id $monitor_ids {
	set selection [ns_db 0or1row $db "select uu.*,to_char(time_when_first_unreachable,'YYYY-MM-DD HH24:MI:SS') as full_unreachable_time, to_char(sysdate(),'YYYY-MM-DD HH24:MI:SS') as full_sysdate, date_part('epoch',sysdate() - time_when_first_unreachable) as n_minutes_downtime from uptime_urls uu
where monitor_id = $monitor_id"]
        if { $selection == "" } {
	    # this row got deleted from the database while we were running this
	    # jump to next iteration
	    continue
	}
	# there was a row in the database
	set_variables_after_query
	# now url, email, a bunch of other stuff are set
	ns_log Notice "Uptime testing $url for $email ..."
	if [catch {set grabbed_text [ns_httpget $url]} errmsg] {
	    ns_log Notice "Uptime failed to reach $url"
	    set grabbed_text "GETURL failed"
	    # let's try once more before raising the alarm
	    if [catch {set grabbed_text [ns_httpget $url]} errmsg] {
		ns_log Notice "Uptime failed to reach $url (second attempt)"
		set grabbed_text "GETURL failed"
	    }
	} else {
	    ns_log Notice "Uptime grabbed something from $url"
	}
	if { [regexp -nocase "success" $grabbed_text] } {
	    # we got it
	    if { $time_when_first_unreachable != "" } {
		# we have the URL on record as having been dead
		ns_db dml $db "update uptime_urls set time_when_first_unreachable = NULL 
where monitor_id = $monitor_id"
                ns_db dml $db "insert into uptime_log
(monitor_id, event_time, event_description)
values
($monitor_id, now(), 'back_up')"
                if { $notification_mode == "down_then_up" } {
		    set n_minutes_downtime [expr round($n_minutes_downtime / 60)]
		    ns_sendmail $email [uptime_system_owner] "$url back up" "$url returned \"success\".  

It was last reached by [uptime_system_name] at $full_unreachable_time ([uptime_system_timezone]).
Currently our database thinks it is $full_sysdate.
In other words, your server has been unreachable for approximately
$n_minutes_downtime minutes.

Does this mean your server was down?  No.  Our server could have lost ITS
network connection.  Or there could have been some problem on the 
wider Internet.

Does this mean your server was actually unreachable for all of those
minutes?  No.  We only sweep every 15 minutes or so
"
                }
	    }
         } else {
	     # we did NOT successfully reach the URL
	     if { $time_when_first_unreachable == "" } {
		 # this is the first time we couldn't get it
		ns_db dml $db "update uptime_urls set time_when_first_unreachable = sysdate(),
last_notification = sysdate()
where monitor_id = $monitor_id"
                ns_db dml $db "insert into uptime_log
(monitor_id, event_time, event_description)
values
($monitor_id, sysdate(), 'down')"
                set subject "$url is unreachable"
                set body "[uptime_system_name] cannot reach $url.  

You may want to check your server.

Does this mean that your server is down?  No.  But as of $full_sysdate
([uptime_system_timezone]), our server is having trouble reaching it.

Oh yes, if you are annoyed by this message and want to desubscribe
to [uptime_system_name], visit 

  [uptime_url_base]delete.tcl?monitor_id=$monitor_id

"
                if { ![string match $custom_subject ""] } {
		    set subject $custom_subject
		}
                if { ![string match $custom_body ""] } {
		    set body $custom_body
		}
		
                ns_sendmail $email [uptime_system_owner] $subject $body
	    } else {
		# site is unreachable, but we already knew that
		if { $notification_mode == "periodic" && [database_to_tcl_string $db "select count(*) 
from uptime_urls
where (sysdate() - last_notification) >  notification_interval_hours/24
and monitor_id=$monitor_id"] == 1 } {
		    # we are supposed to notify periodically and our time 
		    # has come
		    # update the database first so that we don't run wild
		    ns_db dml $db "update uptime_urls set last_notification = sysdate()
where monitor_id=$monitor_id"
                    set subject "$url is unreachable"
                    set body "[uptime_system_name] cannot reach $url.  

You may want to check your server.

Oh yes, if you are annoyed by this message and want to desubscribe
from [uptime_system_name], visit 

  [uptime_url_base]delete.tcl?monitor_id=$monitor_id
"
                    if { ![string match $custom_subject ""] } {
			set subject $custom_subject
		    }
		    if { ![string match $custom_body ""] } {
			set body $custom_body
		    }
		    
		    ns_sendmail $email [uptime_system_owner] $subject $body
		}

	    }
	}
    }
}

proc uptime_monitor_once {service_class {extra_clauses ""}} {
    set db [ns_db gethandle]
    set monitor_ids [database_to_tcl_list $db "select monitor_id
from uptime_urls
where uptime_stale_p(time_when_first_unreachable) = 'f'
and service_class = '$service_class' $extra_clauses"]
    set n_monitors [llength $monitor_ids]
    if { $n_monitors == 0 } {
	ns_log Notice "uptime_monitor_once found 0 monitors matching service_class $service_class (+ $extra_clauses)"
    } else {
	set start_seconds [ns_time]
	ns_log Notice "uptime_monitor_once called for service_class $service_class (+ $extra_clauses) starting to test $n_monitors URLs"
	uptime_monitor_list_of_ids $db $monitor_ids
	set end_seconds [ns_time]
	set elapsed_minutes [expr ($end_seconds - $start_seconds)/60]
	ns_log Notice "uptime_monitor_once finished sweeping $service_class (+ $extra_clauses).  Spent $elapsed_minutes minutes for $n_monitors monitors"
    }
}

proc uptime_monitor_stale {} {
    set db [ns_db gethandle]
    set monitor_ids [database_to_tcl_list $db "select monitor_id
from uptime_urls
where uptime_stale_p(time_when_first_unreachable) = 't'"]
    ns_log Notice "Uptime working on the stale URLs ([llength $monitor_ids] of them)"
    uptime_monitor_list_of_ids $db $monitor_ids
    ns_log Notice "Uptime finished with the stale URLs."
}

ns_share -init {set uptime_already_scheduled 0} uptime_already_scheduled

if { !$uptime_already_scheduled } {
    set uptime_already_scheduled 1
    ns_log Notice "scheduling Uptime monitors"
    # every two minutes, do the gold customers
    ns_schedule_proc -thread 120 uptime_monitor_once gold
    # every five minutes, do the silver customers
    ns_schedule_proc -thread 300 uptime_monitor_once silver
    # every fifteen minutes, do the bronze customers
    ns_schedule_proc -thread 900 { uptime_monitor_once bronze "and lower(url) < 'http://9'" }
    ns_schedule_proc -thread 900 { uptime_monitor_once bronze "and lower(url) >= 'http://9' and lower(url) < 'http://www'" }
    ns_schedule_proc -thread 900 { uptime_monitor_once bronze "and lower(url) >= 'http://www' and lower(url) < 'http://www.m'" }
    ns_schedule_proc -thread 900 { uptime_monitor_once bronze "and lower(url) >= 'http://www.m' and lower(url) < 'http://www.z'" }
    ns_schedule_proc -thread 900 { uptime_monitor_once bronze "and lower(url) >= 'http://www.z'" }
    ns_schedule_daily -thread 23 45 uptime_monitor_stale
    ns_schedule_daily -thread 23 30 uptime_notify_system_owner
}

# stuff to verify that system is working 
 
proc uptime_notify_system_owner {} { 
    set db [ns_db gethandle] 
    set total_entries [database_to_tcl_string $db "select count(*) as total_entries from uptime_log where trunc(event_time) = trunc(sysdate())"]
    ns_sendmail uptime@alal.com uptime@alal.com "Uptime sent $total_entries messages" ""
} 
