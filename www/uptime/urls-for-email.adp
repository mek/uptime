<% 
	# email
	set_form_variables
	set_form_variables_string_trim_DoubleAposQQ
	#ReturnHeaders
	set title "URLs monitored for $email"
%>

<%=[uptime_header $title]%>

by <a href="about.adp"><%=[uptime_system_name]%></a>

<hr>

<ul>

<%
	set db [ns_db gethandle]

	set selection [ns_db select $db "select * from uptime_urls
	where upper(email) = upper('$QQemail')
	order by url"]

	set counter 0

	while {[ns_db getrow $db $selection]} {
    		set_variables_after_query
    		incr counter
    		ns_puts "<li><a href=\"reports.tcl?monitor_id=$monitor_id\">$url</a> (monitored for $name &lt;$email&gt;)\n"
	}

	if { $counter == 0 } {
    		ns_puts "No URLs currently being monitored for \"$email\"\n"
	}

%>

<p>
<li><a href="add-url-form-prestuff.tcl?email=<%=[ns_urlencode $email]%>">Add new URL to be monitored</a>

</ul>

<%=[uptime_footer]%>
