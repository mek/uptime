<%=[uptime_header [uptime_system_name]]%>

Uptime Install Instructions
<hr>

Installation Instructions
<p>
<ol>
<li>You must have AOLserver, Postgres, and nspostgres modules installed.
<p>
<blocktext>
  <ul>
    <li><a href="http://www.aolserver.com">AOLserver</a>.
    <li><a href="http://myturl.com/0001g">AOLserver downloads</a>.
    <li><a href="http://myturl.com/0001h">AOLserver4 Beta 8</a>.
    <li><a href="http://myturl.com/0001i">Postgres Driver for AOLserver 4</a>
    <li><a href="http://myturl.com/0001j">AOLserver 3 downloads (includes Postgres driver)</a> from the <a href="http://www.openacs.org">OpenACS</a> group.
    <li><a href="http://www.postgresql.org">PostgreSQL</a>.
  </ul>
  <p>
  You can find AOLserver installation documentation from <a href="http://www.aolserver.com/docs/admin/install.html">AOLserver</a> or <a href="http://openacs.org/doc/openacs-4-6-3/aolserver.html">OpenACS</a>.
</blocktext>
<p>
<li>Grab the uptime distribution <a href="http://uptime.openacs.org/uptime/doc/uptime-pg-current.tar.gz">http://uptime.openacs.org/uptime/docs/</a>
<p>
<li>Decieded where you want to install the software, I use /web, create the 
directory and extract the tar ball.
<blocktext>
<pre>
# mkdir /web (as root)
# chown nsadmin:web /web
# chmod 700 /web
# su - nsadmin
nsadmin@uptime: cd /tmp
nsadmin@uptime: wget http://uptime.openacs.org/uptime/doc/uptime-pg-current.tar.gz
nsadmin@uptime: cd /web
nsadmin@uptime: gzip -dc /tmp/uptime-pg-current.tar.gz| tar xvf -
</pre>
</blocktext>
<p>
<li>Edit the following files:
<blocktext>
<p>
<ul>
  <li>/web/uptime/etc/uptime.tcl
  <li>/web/uptime/tcl/backup.tcl
  <li>/web/uptime/tcl/uptime-defs.tcl
</ul>
</blocktext>
<p>
<li>Create the postgres database
<blocktext>
<pre>
# su - postgres
postgres@uptime: createuser nsadmin (answer yes to both questions)
postgres@uptime: exit
# su - nsadmin
nsadmin@uptime: createdb uptime
nsadmin@uptime: psql -f /web/uptime/www/uptime/doc/sql/postgres.sql uptime
nsadmin@uptime: psql -f /web/uptime/www/uptime/doc/sql/data-model.sql uptime
</pre>
</blockquote>
<p>
</ol>
Start the AOLserver for uptime and everything should be running.
<p>
Included are some crontab entries uptime.crontab.  You may choose to 
use them if you want.
<p>
<%=[uptime_footer]%>
