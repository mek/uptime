<%=[uptime_header [uptime_system_name]]%>

<p>

<% 

	set db [ns_db gethandle]
	ns_puts "Currently there are [database_to_tcl_string $db "select count(monitor_id) from uptime_urls"] sites being monitored."

%>
<P>

An uptime monitoring system, provided as a service to the entire
Internet by <a href="http://www.openacs.org/">OpenACS</a>.  This is a postgres port of the <a href="http://www.arsdigita.com">Arsdigita's</a> uptime services.  You can read the <a href="old-about.adp">About</a> page that came with their software.

<p>

(Contributors  for the origianl software were 
Jin Choi, <a href="http://photo.net/philg/">Philip
Greenspun</a>).

<p>

<a href="mailto:mkovach-uptime@alal.com">Mat Kovach</a> contributed the software
that is currently running on this server (and he runs the server).  Additional 
docs and future plans are <a href="/uptime/doc">available</a> here.

<p>

<hr>

<h3>What it does</h3>

Uptime periodically requests a page from your server.  If the site is
unreachable, Uptime sends you email.  Uptime will continue checking
your site.  When it becomes reachable again, Uptime will send you one
more message.

<p>

If you wish to be beeped by Uptime, then you need only subscribe to a
beeper service that has an email gateway.  You can give Uptime a
custom subject line or message body if your beeping service needs a
specially formatted message.

<p>

What's the period?  Right now, the average user's server gets queried
every 15 minutes.  We have "gold" and "silver" users who get
queried every two or five minutes.  These are generally friends of
ours or people who help support this site in some way.


<h3>OK, I'm ready to start</h3>

Well, then just <a href="add-url.html">add a new url to the
system</a> and take it from there.  If you already added your site,
<a href="index.adp">go and enter your email address</a> or 
<a href="search-list-of-urls.tcl">look at the complete list of
sites registered in this system</a>.

<h3>Underlying Technology</h3>

This is yet another example from the book <a
href="http://photo.net/wtr/thebook/"><cite>Philip and Alex's Guide to Web Publishing</cite></a>.  We wrote it in Tcl for the
NaviServer (AOL Server) API and the back-end is an Oracle 8 relational
database.  The software is pretty simple.  The hard part is keeping a
relational database up and running 7 days/week, 24 hours/day.

<%=[uptime_footer]%>
