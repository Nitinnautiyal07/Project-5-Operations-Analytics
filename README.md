# Project-5-Operations-Analytics
Operation Analytics using MYSQL
Operation Analytics is the analysis done for the complete end to end
operations of a company.
This will help company to find areas on which it must improve upon.
Being one of the most important parts of a company, this analysis is further
used to predict the overall growth or decline of a company’s fortune, which
means better automation, better understanding between cross-
functional teams, and more effective workflows.

## Here is the complete code for it.

#1-Data impor

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


## Operation Metrics

#1: Calculate the number of jobs reviewed per hour per day for November 2020?
SELECT
        ds as date,
        COUNT(job_id) / 24 AS no_of_job_reviewed FROM jobs 
    GROUP BY ds 
    ORDER BY no_of_job_reviewed;
 
 #2Calculate 7 day rolling average of throughput?
 #For throughput, do you prefer daily metric or 7-day rolling and why?
 
 with throughput as (
 SELECT *,sum(1/time_spent) Over(partition by job_id) as no_of_jobs_reviewed_per_second
 FROM jobs
 order by no_of_jobs_reviewed_per_second
 )
 select * ,
 truncate(avg(no_of_jobs_reviewed_per_second) over(order by ds ROWS BETWEEN 3 PRECEDING AND CURRENT ROW),2)
 as rolling_average from throughput;
 
 #3 Calculate the percentage share of each language in the last 30 days?
select count(distinct language) from jobs;
 
 with cte1 as (
 select event,language,count( language) as no_of_languages,
 count(distinct language)as total_languages from jobs
 group by language
 )
 select *,round(no_of_languages*100/(select count( language) from jobs)
,2) as pct  from cte1
 group by language;

#4 Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?

select *,count(job_id) from jobs
group by job_id
having count(job_id)>1;

##5-weekly users enagement

select 
       extract(week from occurred_at) as week,count(distinct user_id) as weekly_active_users from events
       where event_type="engagement" and event_name="login"
       group by  extract(week from occurred_at);
       
##-6: Calculate the user growth for product?

select   monthname(created_at) as Month,
       count(user_id) as Users_registered_monthwise from users
       where activated_at !='0000-00-00 00:00:00'
       group by month;
       
##7:  Calculate the weekly engagement per device?*
       
SELECT  extract(year from occurred_at) as Year,extract(week from occurred_at) as week_no, device,
        count(distinct user_id ) as Weekly_users_enagement_per_device from events
        where occurred_at !='0000-00-00 00:00:00' and event_type='engagement'
        group by extract(year from occurred_at) ,extract(week from occurred_at) , device;
        
##8:Calculate the email engagement metrics?

with email_events as (
			select *,
	Case
        when action in('sent_weekly_digest','sent_reengagement_email') then 'email_sent'
        when action in('email_clickthrough') then 'clicked_email'
        when action in('email_open') then 'email_opened'
	end as e_mail
	from email
    )
select 
sum(case when e_mail='email_opened' then 1 else 0 end)*100/sum(case when e_mail='email_sent' then 1 else 0 end)
as rate_of_opened_email,
sum(case when e_mail='clicked_email' then 1 else 0 end)*100/sum(case when e_mail='email_sent' then 1 else 0 end)
as rate_of_clicked_email
from email_events;

#9-Calculate the weekly retention of users-sign up cohort?
with cte as (

select DATEDIFF('2014-09-01',activated_at) AS user_age ,u.user_id,occurred_at
from users u 
join events e
on u.user_id=e.user_id
)
select extract(week from occurred_at) as 'week',
count(distinct case when user_age<63 and user_Age >=56 then user_id else null end) as '8+ weeks',
count(distinct case when user_age<56 and user_Age >=49 then user_id else null end) as '7 weeks',
count(distinct case when user_age<49 and user_Age >=42 then user_id else null end) as '6 weeks',
count(distinct case when user_age<42 and user_Age >=49 then user_id else null end) as '5 weeks',
count(distinct case when user_age<49 and user_Age >=28 then user_id else null end) as '4 weeks',
count(distinct case when user_age<28 and user_Age >=21 then user_id else null end) as '3 weeks',
count(distinct case when user_age<21 and user_Age >=14 then user_id else null end) as '2 weeks',
count(distinct case when user_age<14 and user_Age >=7 then user_id else null end) as '1 weeks',
count(distinct case when user_age<7 and user_Age >=1 then user_id else null end) as 'less than one week'
from cte
group by week;
                  
















