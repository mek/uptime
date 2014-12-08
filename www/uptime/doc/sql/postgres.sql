--
-- The Postgres specific hacks
--
-- Ben Adida (ben@adida.net)
--

-- Uncomment these two lines and comment the two below if
-- you have the RPM version of PostgreSQL
--
--create function plpgsql_call_handler() RETURNS opaque
--as '/usr/lib/pgsql/plpgsql.so' language 'c';
--
create function plpgsql_call_handler() RETURNS opaque
as '/usr/local/pgsql/lib/plpgsql.so' language 'c';

create trusted procedural language 'plpgsql'
HANDLER plpgsql_call_handler
LANCOMPILER 'PL/pgSQL';

-- standard sysdate call
create function date_standardize(timestamp with time zone) returns varchar as '
declare
	the_date alias for $1;
begin
	return date_part(''year'',the_date) || ''-'' || lpad(date_part(''month'',the_date),2,''0'') || ''-'' || lpad(date_part(''day'',the_date),2,''0'');
end;
' language 'plpgsql';

-- DRB sez: ''now''::datetime gets evaluated at compile time, due to
-- the cast, apparently.  Not what we want!  ''now'' alone, cast
-- implicitly when the call or a return is executed, appears to work.
-- Gaack?  Yep.

create function sysdate_standard() returns varchar as '
begin
	return date_standardize(''now'');
end;
' language 'plpgsql';

-- sysdate hack to make things look somewhat alike
create function sysdate() returns timestamp with time zone as '
begin
	return ''now'';
end;' language 'plpgsql';

-- DRB's hack for the system table 'dual' - the call to sysdate()
-- is executed each time dual's referenced.  Using a view like this
-- means that "select sysdate from dual" works fine.  Since a single
-- row is always returned, you can select any expression as well
-- and it works.

create view dual as select sysdate();
 
-- date trunc
create function trunc(timestamp with time zone) returns timestamp with time zone as '
declare
	the_date alias for $1;
begin
	return date_trunc(''day'',the_date);
end;
' language 'plpgsql';

create function trunc(timestamp with time zone, varchar) returns timestamp with time zone
as '
DECLARE
	the_date alias for $1;
	the_pattern alias for $2;
BEGIN
	return date_trunc(the_pattern, the_date);
END;
' language 'plpgsql';

-- Get the last day of a month
create function last_day(timestamp with time zone) returns timestamp with time zone
as '
DECLARE
	the_date alias for $1;
BEGIN
	return date_trunc(''Month'', the_date + ''1 month''::reltime) - ''1 day''::reltime;
END;
' language 'plpgsql';

-- Julian date
-- create function to_date_from_julian(numeric) 
-- returns timestamp with time zone as '
-- DECLARE
--	the_julian alias for $1;
-- BEGIN
-- 	return ''0000-01-01 12:00:00''::timestamp with time zone + (( the_julian - 1721058 ) || '' day'')::reltime;
-- END;
-- ' language 'plpgsql';

-- Julian date (as modified by Michael A. Cleverly, 30 mar 2000)
-- May need to be checked and reconciled with the above
create function to_date_from_julian(numeric) 
returns date as '
DECLARE
	the_julian alias for $1;
BEGIN
	return ''0000-01-01''::date + ( the_julian - 1721060 );
END;
' language 'plpgsql';

-- sign
-- drop function sign(float4);
create function sign(float4) returns integer as '
declare
	the_number alias for $1;
begin
	if the_number >=0 then return 1;
	else return -1;
	end if;
end;
' language 'plpgsql';

-- drop function sign(interval);
create function sign(interval) returns integer as '
declare
	the_interval alias for $1;
begin
	if date_part(''day'',the_interval) >=0 then return 1;
	else return -1;
	end if;
end;
' language 'plpgsql';


-- date stuff
create function date_num_days(timespan) returns numeric as '
DECLARE
	the_span alias for $1;
	num_days numeric;
BEGIN
	num_days:= date_part(''day'', the_span);
	num_days:= num_days + ((date_part(''hour'', the_span)/24)::numeric);

	RETURN num_days;
END;
' language 'plpgsql';

create function timespan_days(integer) returns timespan as '
DECLARE
	n_days alias for $1;
BEGIN
	return (n_days || '' days'')::timespan;
END;
' language 'plpgsql';

-- Mimic Oracle's negation of character-based pseudo-bools

create function logical_negation(char) returns char as '
BEGIN
	IF ($1 = ''f'') THEN RETURN ''t'';
	ELSE RETURN ''f'';
    END IF;
END;
' language 'plpgsql';

-- Negate a REAL bool, in case we get smart and use SQL92's built-in
-- bool type, which is fully supported by PG.  Of course, we should
-- weed out calls to this function for efficiency reasons, but this
-- will keep things running in the interim.

create function logical_negation(bool) returns bool as '
BEGIN
	RETURN NOT $1;
END;
' language 'plpgsql';


create function round(integer) returns integer
as '
DECLARE
	the_int alias for $1;
BEGIN
	return round(the_int,0);
END;
' language 'plpgsql';

-- Mimic Oracle's months_between built-in

create function months_between(timestamp, timestamp) returns real
as '
begin
    return date_part(''year'', age($1, $2)) * 12.0 + date_part(''month'', age($1, $2)) +
        date_part(''day'', age($1, $2)) / 31.0;
end;' language 'plpgsql';

-- Mimic Oracle's user_tab_columns table (thanks Ken Mayer!)

CREATE VIEW user_tab_columns AS
SELECT upper(c.relname) AS table_name, 
       upper(a.attname) AS column_name,
       CASE WHEN (t.typprtlen > 0)
       THEN t.typprtlen
       ELSE (a.atttypmod - 4)
       END AS data_length
FROM pg_class c, pg_attribute a, pg_type t
WHERE (a.attrelid = c.oid) AND (a.atttypid = t.oid) AND (a.attnum > 0);

