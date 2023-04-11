create table users(
user_id int,
created_at datetime,
company_id int,
language varchar(30),
activated_at datetime,
state varchar(30)
);
load data  infile "F:\Table-1 users.csv"  into table users
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(user_id ,created_at ,company_id ,language ,activated_at ,state );

update users
set activated_at
 ="0000-00-00 00:00:00"
where activated_at
='1900-01-00 00:00:00';


## importing events file

create table events(
user_id int,
occurred_at datetime,
event_type varchar(40),
event_name varchar(30),
location varchar(30),
device varchar(30),
user_type int
);
load data  infile "F:\Table-2 events.csv"  into table events
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(user_id ,occurred_at ,event_type ,event_name ,location ,device,user_type );

update events
set occurred_at ="0000-00-00 00:00:00"
where occurred_at='1900-01-00 00:00:00';

## importing email file.
SET GLOBAL local_infile=1;


create table email(
user_id int,
occurred_at datetime,
action varchar(30),
user_type int
);
load data  infile "F:\Table-3 email_events.csv"  into table email
fields terminated by ','
lines terminated by '\r\n'
ignore 1 lines
(user_id ,occurred_at ,action ,user_type );


