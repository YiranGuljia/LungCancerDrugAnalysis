FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/poss.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.poss;
	GETNAMES=YES;
RUN;

data possess;
set poss (rename=(monodate=evttime monodate_n=evt_n));
evt="肿瘤增大";
keep id evt evttime evt_n;
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/deathid.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.dth;
	GETNAMES=YES;
RUN;

data death;
set dth (rename=(deathdate=evttime deathdate_n=evt_n TypeName=evt));
keep id evt evttime evt_n;
run;

proc sort data=possess;
by id;
run;

proc sort data=death out=dead;
by id;
run;

data evnt;
set dead (drop=evttime) possess (drop=evttime) ;
by id;
run;

proc sort data=evnt out=evntsort;
by id evt_n;
run;

data evntnodup;
set evntsort;
by id;
if not first.id then delete;
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate03.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt03;
	GETNAMES=YES;
RUN;

data eventtime;
merge plt03 (in=a) evntnodup (in=b);
by id;
if a and b;
surtime=round(evt_n-scrdate_n);
event=1;
drop scrhosp empi nohops ssn tele nohops location;
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate15.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt15;
	GETNAMES=YES;
RUN;

data medgrpx;
set plt15;
if med="乌苯美司胶囊(百士欣)" then grp1="乌苯美司";
else if med="！埃克替尼片(凯美纳)" or med="厄洛替尼片（特罗凯）" or
med="(吉泰瑞)阿法替尼片（30mg)" or 
med="[危]埃克替尼片(凯美纳)" or med="埃克替尼片(凯美纳)" or
med="吉非替尼片(伊瑞可)" or med="吉非替尼片(易瑞沙)" or med="贝伐珠单抗针(安维汀)"
then grp1="靶向药";
else if med= "！国产卡铂针（国产）" or med="卡铂针(伯尔定)" or
med="！进口卡铂针(伯尔定)" or med="进口卡铂针(伯尔定)" or med="奈达铂针" or
med="！奈达铂针" or med="！顺铂针(大剂量)" or  med="卡铂针（国产）" or
med="(捷佰舒)注射用奈达铂" or med="[危]进口卡铂针(伯尔定)" or
med="(诺欣)顺铂注射液[基]" or med="[危]国产卡铂针（国产）" or
med="[危]奈达铂针" or med="[危]顺铂针(大剂量)" or med="国产卡铂针（国产）" or
med ="顺铂针(大剂量)" or med="注射用卡铂[基]"
then grp1="铂类";
else if  med="百令胶囊" or med="百令胶囊[基]" then grp1=med;
else if med="国产胸腺肽α1针" or med="国产胸腺肽α1针迈普新" or
med="进口胸腺肽针α1日达仙" or med="胸腺肽α1针（迈普新）" or
med="胸腺肽α1针迈普新/皮注" or med="胸腺肽肠溶片(大剂量)" or
med="胸腺肽针α1日达仙"
then grp1="胸腺肽类";
else grp1="化疗类";
keep sex age id med startdate enddate dosechar dosew dosefrq days grp1;
run;

data medgrp1;
set medgrpx (where=(grp1="乌苯美司"));
grp2=grp1;
keep id grp2 startdate;
run;

data medgrp2;
set medgrpx (where=(grp1="化疗类"));
grp3=grp1;
keep id grp3 startdate;
run;

data medgrp3;
merge medgrp1 (in=a rename=(startdate=mstdate)) medgrp2 (in=b);
by id;
if a and b then grp="乌苯美司+化疗";
else if b then grp="化疗";
if missing(grp) then delete;
run;

proc sort data=medgrp3 out=medgrp;
by id grp;
run;

data medgrp;
set medgrp;
by id;
if first.id;
run;

/*proc export data=medgrp
outfile='/folders/myfolders/LungCancerDatasets/medgrp.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

proc export data=eventtime
outfile='/folders/myfolders/LungCancerDatasets/eventtime.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;*/

data evtgrp;
merge medgrp (in=a) eventtime (in=b);
by id;
if a and b;
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate16.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt16;
	GETNAMES=YES;
RUN;

proc sql;
create table typx as 
select * from plt16
where desp contains '小细胞';
quit;

proc sql;
create table typxf as
select * from typx
where desp contains '非小细胞';
quit;

proc sql;
create table typex as
select id from typx
except select id from typxf;
quit;

proc sql;
create table typef as
select id from plt16
except select id from typex;
quit;

data typ;
set typex (in=a) typef (in=b) ;
if b then type="非小细胞肺癌";
if a then type="小细胞肺癌";
proc sort;
by id;
run;

data suranalys;
merge evtgrp (in=a) typ (in=b) ;
by id;
if a and b;
drop grp2 grp3 diag;
run;

proc export data=suranalys
outfile='/folders/myfolders/LungCancerDatasets/suranalys1.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;
