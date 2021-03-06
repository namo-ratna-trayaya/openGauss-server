create schema distribute_stat;
create schema distribute_stat2;
set current_schema = distribute_stat;

create table test_analyze(f1 int, f2 float, f3 text);
insert into test_analyze select generate_series(1,1000), 10.0, repeat('Gauss Database,Niubility!!',2);

analyze test_analyze;
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;

analyze verbose test_analyze;
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;

--test analyze column
delete from pg_statistic where exists(select 1 from pg_class where  oid=starelid and relname = 'test_analyze');
analyze test_analyze(f2,f1);
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;

delete from pg_statistic where exists(select 1 from pg_class where  oid=starelid and relname = 'test_analyze');
analyze test_analyze(f1,f1);
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;
select count(distinct f1) from test_analyze;

---test for null table
delete from test_analyze;
analyze test_analyze;
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze';
select staattnum,stanullfrac,stadistinct from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;

---test for nullfrac
insert into test_analyze select generate_series(1,1000), 10.0, null;
delete from pg_statistic where exists(select 1 from pg_class where  oid=starelid and relname = 'test_analyze');
analyze test_analyze(f3);
select staattnum,stanullfrac,stadistinct from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;
select count(distinct f3) from test_analyze;

create unique index test_analyze_index on test_analyze(f1);
vacuum analyze test_analyze;
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze_index';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers2,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze_index' order by staattnum;

delete from pg_statistic where exists(select 1 from pg_class where  oid=starelid and relname = 'test_analyze');
vacuum analyze public.test_analyze;
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers2,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze' order by staattnum;


--test for ORIENTATION COLUMN
create table test_analyze_col(f1 bigint, f2 int, f3 char(10)) WITH (ORIENTATION = COLUMN) ;
insert into test_analyze_col select generate_series(1,1000), generate_series(1,1000), 'col'|| generate_series(1,1000);

select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze_col';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze_col' order by staattnum;

analyze test_analyze_col(f2,f1);
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze_col';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze_col' order by staattnum;

delete from pg_statistic where exists(select 1 from pg_class where  oid=starelid and relname = 'test_analyze_col');
analyze verbose test_analyze_col;
select relpages > 0 as relpagesgtzero,reltuples > 0 as reltuplesgtzero from pg_class where relname = 'test_analyze_col';
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze_col' order by staattnum;

set default_statistics_target=0;
analyze test_analyze_col;
reset default_statistics_target;

analyze test_analyze_col;
truncate table test_analyze_col;
vacuum full test_analyze_col;

delete from test_analyze_col;
analyze test_analyze_col;
select starelkind,staattnum,stainherit,stanullfrac,stawidth,stadistinct,stakind1,stakind2,stakind3,stakind4,stakind5,staop1,staop2,staop3
,staop4,staop5,stanumbers1,stanumbers3,stanumbers4,stanumbers5
 from pg_statistic sta join pg_class cla on sta.starelid=cla.oid where relname = 'test_analyze_col' order by staattnum;

create index test_i on test_analyze_col(f1);
analyze test_analyze_col(f2);

reset current_schema; 
drop schema distribute_stat cascade;
drop schema distribute_stat2 cascade;
