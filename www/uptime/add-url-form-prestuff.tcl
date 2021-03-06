set_form_variables
set_form_variables_string_trim_DoubleAposQQ

# email

set db [ns_db gethandle]

# there may be many names for one email address in the database but we
# only want one so we kludge with max

set full_name [database_to_tcl_string $db "select max(name) from uptime_urls where upper(email) = upper('$QQemail')"]


ns_return $conn 200 text/html "<html>
<head>
<title>Add URL</title>
</head>
<body bgcolor=#ffffff text=#000000>
<h2>Add URL</h2>

to <a href=\"about.adp\">Uptime</a>

<hr>

<form method=post action=\"add-url.tcl\">

<h3>Fundamentals</h3>

Next, we need to know the URL that you want monitored.  This must be a
page that returns the word \"success\".  You will have to create a file,
e.g., \"uptime.txt\", on your server that contains just this one word.

<p>

Monitored URL :  <input type=text name=url size=40 value=\"http://\">

<P>

We need to know where to send email when the monitored URL does not
return \"success\" (or is completely unreachable).  Normally, this would
be your everyday email address, but if you are using a beeper service
then put in their address.  (Note: if you want to be notified in your
regular email box <em>and</em> beeped then just fill out this form
twice, once with each email address where you want to receive
notifications.)

<p>

Email Address:  <input type=text name=email size=30 value=\"$email\">

<p>

In order to build you a nice user interface, we need to know the main
URL for your site, e.g., \"http://www.yourdomain.com/\".

<p>

Homepage URL:  <input type=text name=homepage_url size=40 value=\"http://\">


<h3>About You</h3>

Your Name:  <input type=text name=name size=40 value=\"$full_name\">

<h3>Options</h3>

You can change these later, so don't agonize too much... 

<p>

Uptime can work in two modes.  One: you get email when
your server goes down and then one more message when it comes back up.
This is probably what you want.  Two: you get email only when your
server goes down; if your server remains down, you'll get email at the
time interval that you specify.  This is probably what you want if you
are directing notifications to a beeper company.

<p>

<input type=radio name=notification_mode value=down_then_up CHECKED> Email when down then again when up
<input type=radio name=notification_mode value=periodic> Periodic

<p>

Notification Interval (hours):  <input type=text name=notification_interval_hours value=2>

<br>
(note: this field is ignored unless you have selected periodic notification)

<h3>Password</h3>

You don't want random people looking at your uptime logs or deleting
your monitored URL.

<p>

Password:  <input name=password type=text size=15>

<p>

(note: if you forget your password, our software will offer to email it
to you)

<p>

<input type=submit value=\"Enter This New URL in the Database\">

</form>

<hr>
<a href=\"mailto:[uptime_system_owner]\"><address>[uptime_system_owner]</address></a>

</body>
</html>
"
