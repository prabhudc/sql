create local temporary table #t1 ( key1 integer, key2 integer, tim1 nvarchar(10), tim2 nvarchar(10));
insert into #t1 values (10001,20001, '20150801','20150801');
insert into #t1 values (10001,30001, '20150801','20150810');
insert into #t1 values (10001,20002, '20150910','20150910');
insert into #t1 values (10001,20002, '20150915','20150910');
insert into #t1 values (10001,20002, '20170115','20170110');
insert into #t1 values (10001,20002, '20170115','20170410');
create local temporary table #t2 ( key1 integer , tim1 nvarchar(10), tim2 nvarchar(10), val1 nvarchar(20));
insert into #t2 values (10001, '20150701','20150201', 'initial value 1');
insert into #t2 values (10001, '20150807','20150911', 'initial value 2');
insert into #t2 values (10001, '20160101','20161001', 'initial value 3');
insert into #t2 values (10001, '20160101','20160501', 'initial value 4');
insert into #t2 values (10001, '20160601','20160601', 'initial value 5');
select a.key1, a.tim1, a.tim2, b.val1
from
      (select key1,  tim1, tim2 , src, src_a,
                  first_value(tim1) over (partition by key1,temp_cnt  order by tim1, tim2)  as "valid_frm",
                  first_value(tim2) over (partition by key1,temp_cnt  order by tim1, tim2)  as "eff_frm"
      from
            (select key1,  tim1, tim2 , src, src_a,
                        count(src_a) over (partition by key1 order by tim1, tim2) as temp_cnt
            from
            (
                  select key1,  tim1, tim2 , 'A' as src, 'true' as src_a   from #t2
                  union
                  select key1,  tim1, tim2 , 'B' as src, null as src_a   from #t1
            )     
            )
      ) a
      left outer join #t2  b
      on a.key1 = b.key1 and a."valid_frm" = b.tim1 and a."eff_frm" = b.tim2
      where a.src = 'B'
;