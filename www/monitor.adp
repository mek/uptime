<%
	set connections [ns_server active]

	# let's build an ns_set just to figure out how many distinct elts; kind of a kludge
	# but I don't see how it would be faster in raw Tcl
	set scratch [ns_set new scratch]
	foreach connection $connections {
    		ns_set cput $scratch [lindex $connection 1] 1
	}

	set distinct [ns_set size $scratch]

	# run standard Unix uptime command to get load average (crude measure of
	# system health)

	set uptime_output [exec /usr/bin/uptime]
	set title "Life on the [ns_info server] server"
%>

<%=[uptime_header $title]%>

There are a total of <%=[llength $connections]%> requests being served
right now (to $distinct distinct IP addresses).  Note that this number
seems to include only the larger requests.  Smaller requests, e.g.,
for .html files and in-line images, seem to come and go too fast for
this program to catch.

<p>

AOLserver says that the max number of threads spawned since server
startup is <%=[llength [ns_info threads]]%>.  

<p>

Here's what uptime has to say about the box:

<pre>
$uptime_output
</pre>

<table>
<tr><th>conn #<th>client IP<th>state<th>method<th>url<th>n seconds<th>bytes</tr>

<%

	foreach connection $connections {
    		ns_puts "<tr><td>[join $connection <td>]\n"
	}
%>


</table>

<%=[uptime_footer]%>
