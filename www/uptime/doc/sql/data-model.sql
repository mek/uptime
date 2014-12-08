--
-- data model for the Uptime Web server monitoring system
-- 
-- copyright 1997 Cotton Seed (cottons@lcs.mit.edu) 
-- and Philip Greenspun (philg@mit.edu)
--
-- converted to Oracle 4/30/98 by philg
--
-- converted to Postgres 6/8/2001 by Mat Kovach <mkovach@alal.com>

-- service_class should be bronze, silver, or gold

create sequence uptime_monitor_sequence start 5000;

create table uptime_urls (
	monitor_id	integer not null primary key,
	url		varchar(200) not null,
	name		varchar(100) not null,
	email		varchar(100) not null,
	password	varchar(30) not null,
	homepage_url	varchar(200),
	service_class	varchar(30) default 'bronze',
	first_monitored	timestamp with time zone,
	-- the following are for people who have beepers
	-- and need a special tag or something in the subject
	custom_subject	varchar(4000),
	custom_body	varchar(4000),
	-- we always send email when the server is down, we can
	-- also send email when the server comes back up
	notification_mode	varchar(30), 	-- 'down_then_up', 'periodic'
	-- these two are only used when notification_mode is 'periodic'
	notification_interval_hours	integer default 2,
	last_notification	timestamp with time zone,
	-- if this is NULL, it means that we've sent a BACK UP notification
	time_when_first_unreachable	timestamp with time zone,
	unique(url,email)
);



-- stale if it is unreachable and hasn't been reached for 10 days

create or replace function uptime_stale_p(timestamp with time zone) returns varchar as '
begin
        IF $1 is null THEN
            return ''f'';
        ELSE
            if $1 > (timestamp ''now()'' - interval ''10 days'') THEN
                return ''f'';
            ELSE
                return ''t'';
            END IF;
        END IF;
        return result;
end;' language 'plpgsql';


create table uptime_log (
	monitor_id		integer not null references uptime_urls,
	event_time		timestamp with time zone,
	event_description	varchar(100)
);

create index uptime_log_idx on uptime_log (monitor_id);


create table uptime_url_stats (
        url                     varchar(200) not null primary key,
        n_days_monitored        integer not null,
        n_outages               integer not null
);
