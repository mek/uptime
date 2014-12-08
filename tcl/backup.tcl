### Backup Script, pretty much the one Don Baccus include in his OpenACS docs
proc backup {} {	
    set b "/usr/lib/postgresql/bin" 
    set bak "/web/uptime/backup" 	  
    set db [ns_db gethandle] 
    set sql "select date_part('day','today'::date) as day" 
    set selection [ns_db 1row $db $sql] 
    set_variables_after_query 
    set data "uptime_$day.dmp"
   
    ns_log Notice "Backup of [uptime_system_name] starting."
    ns_log Notice "pg_dump beginning..." 	
    if [catch {append msg [exec "$b/pg_dump" "uptime" ">$bak/$data"]} errmsg] { 
	ns_log Error "pg_dump failed: $errmsg" 
	ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : pg_dump failed..." "$errmsg" 
	ns_db releasehandle $db 
	return 
    }	   
    append msg "\n"
    
    ns_log Notice "gzip of data beginning..." 	
    if [catch {append msg [exec "gzip" "-f" "$bak/$data"]} errmsg] { 
	ns_log Error "gzip of data failed: $errmsg" 
	ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : gzip of data failed..." "$errmsg" 
	ns_db releasehandle $db 
	return 
    }	
    append msg "\n"
  
    ns_log Notice "ftp data beginning..." 
    set fd [open "$bak/ftp_data.tmp" w]	
    puts $fd "user USERNAME PASSWORD\nbinary\nput $bak/$data.gz BACKUPDIR/$data.gz\nquit\n" 
    close $fd	
    if [catch {append msg [exec "ftp" "-n" "HOSTNAME" "<$bak/ftp_data.tmp"]} errmsg] { 
	ns_log Error "ftp data failed: $errmsg" 
	ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : ftp data failed..." "$errmsg" 
	ns_db releasehandle $db 
	return 
    }
    if [catch {append msg [exec "rm" "-f" "$bak/ftp_data.tmp"]} errmsg] {
	ns_log Error "Failed to remove $bak/ftp_data.tmp"
	ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : removing of ftp tmp file failed..." "$errmsg"
	ns_db releasehandle $db
	return
    } 
    append msg "\n"
  
    ns_log Notice "vacuum beginning..." 	
    if [catch {append msg [exec "$b/vacuumdb" "-q" "-z" "uptime"]} errmsg] { 
	ns_log Error "vacuum failed: $errmsg" 
	ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : vacuum failed..." "$errmsg" 
	ns_db releasehandle $db return 
	return
    }
  
    ns_db releasehandle $db 
    ns_log Notice "Backup succeeded." 
    append msg "Backups succeeded"
    ns_sendmail [uptime_system_owner] [uptime_system_owner] "[uptime_system_name] : backup succeeded" "$msg" 
}	 

ns_share -init {set schedule_backup 0} schedule_backup
if {!$schedule_backup} { 
    ns_schedule_daily 0 0 backup 
    ns_log Notice "Backup has been scheduled." 
}
