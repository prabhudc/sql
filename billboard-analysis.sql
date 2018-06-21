create table  ratings(
        url  varchar(500), 
        weekid varchar(10),
        position varchar(10), 
        song nvarchar(500), 
        performer nvarchar(500), 
        songid nvarchar(500), 
        instance varchar(10), 
        previous_week varchar(10),
        peak_position varchar(10), 
        weeks_on_char varchar(10)
);


create column table rating as (Select * from ratings);

select * from rating;

select performer, count(distinct(weekid))
from rating
group by performer
order by count(distinct(weekid)) desc;



select song,performer, count(*) as count
from rating
group by song,performer
order by count(*) desc

-- no. of weeks on top 5

select performer, count(*)  as count
from(
	select *
	from rating 
	where position <= 5
)
group by performer
order by count(*) desc

--Biggest gap in getting back to the top 5

select *
from(
	select performer,
		weekid,
		lead(weekid) over( partition by performer order by weekid) prev_weekid,
		to_decimal(days_between(weekid,
		lead(weekid) over( partition by performer order by weekid))/(7*54),10,2)  as gap
		from
		(
			select performer,to_date(weekid)  as weekid
			from rating
			where position <= 5
			order by to_date(weekid) desc
		)
)
order by gap desc
;


select performer, freq, count(*) + 1 as RUN_COUNT
from
 (
	select
		performer,
		weekid,		
		sum(gap) over(partition by performer order by weekid) freq,
		gap
		from
		(
		select performer,
			weekid,			
			case when add_days(weekid,7) = lead(weekid) over( partition by performer order by weekid)
			then 1
			else null
			end as gap
			from
			(
				select performer,to_date(weekid)  as weekid
				from rating
				where position = 1
				order by to_date(weekid) desc
			)
	    --where performer = 'Fergie'
  )
)
where freq is not null
group by performer,freq
order by count(*) desc




select performer,song, freq, count(*) + 1 as RUN_COUNT
from
 (
	select
		performer,song,
		weekid,		
		sum(gap) over(partition by performer,song order by weekid) freq,
		gap
		from
		(
		select performer,song,
			weekid,			
			case when add_days(weekid,7) = lead(weekid) over( partition by performer,song order by weekid)
			then 1
			else null
			end as gap
			from
			(
				select performer,song,to_date(weekid)  as weekid
				from rating
				where position = 1
				order by to_date(weekid) desc
			)
	    --where performer = 'Fergie'
  )
)
where freq is not null
group by performer, song,freq
order by count(*) desc


		
