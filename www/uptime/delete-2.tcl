set_the_usual_form_variables

# monitor_id, password

set db [ns_db gethandle]

set password_from_db [database_to_tcl_string $db "select password
from uptime_urls
where monitor_id = $monitor_id"]

set email [database_to_tcl_string $db "select email
from uptime_urls
where monitor_id = $monitor_id"]

if { [string compare [string trim [string toupper $password]] [string trim [string toupper $password_from_db]]] != 0 } {
    ns_returnredirect $conn "bad-password.tcl?monitor_id=$monitor_id"
    return
}

# if we got here, the password matched

ns_db dml $db "begin transaction"
ns_db dml $db "delete from uptime_log where monitor_id = $monitor_id"
ns_db dml $db "delete from uptime_urls where monitor_id = $monitor_id"
ns_db dml $db "end transaction"

ns_returnredirect $conn "urls-for-email.adp?email=[ns_urlencode $email]"
