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
else if  med="百令胶囊" or med="百令胶囊[基]" then grp1="百令";
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
keep id grp2;
run;

data medgrp2;
set medgrpx (where=(grp1="化疗类" or grp1="铂类"));
grp3=grp1;
keep id grp3;
run;

data medgrp3;
set medgrpx (where=(grp1="靶向药"));
grp4=grp1;
keep id grp4;
run;

data medgrp4;
set medgrpx (where=(grp1="百令"));
grp5=grp1;
keep id grp5;
run;

data medgrp5;
set medgrpx (where=(grp1="胸腺肽类"));
grp6=grp1;
keep id grp6;
run;

data medgrpnew;
merge medgrp1 (in=a) medgrp2 (in=b)
medgrp3 (in=c) medgrp4 (in=d) medgrp5 (in=e);
by id;
if a and b and not c and not d and not e then grp="乌苯美司+化疗（含铂类）";
else if b and not c and not d and not e then grp="化疗（含铂类）";
if missing(grp) then delete;
run;

proc sort data=medgrpnew;
by id;
run;

data medgrpn;
set medgrpnew;
by id;
if first.id;
run;

proc export data=medgrpn
outfile='/folders/myfolders/LungCancerDatasets/mdgrpnfinal.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;


data evtgrp;
merge medgrpn (in=a) eventtime (in=b);
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
outfile='/folders/myfolders/LungCancerDatasets/suranalys03.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/censor.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt04;
	GETNAMES=YES;
RUN;

proc sort data=plt04;
by id discharge;
run;

data cnsrnodup;
set plt04;
by id discharge;
if last.id;
drop sex age;
run;

data cnsr;
merge plt03 (in=a) cnsrnodup (in=b);
by id;
if a and b;
surtime=round(discharge-scrdate_n);
event=0;
if surtime>0;
drop scrhosp empi nohops ssn tele nohops location;
run;


data cnsrgrp;
merge cnsr (in=a) medgrpn (in=b);
by id;
if a and b;
*drop grp2-grp6;
run;

data cnsranalys;
merge cnsrgrp (in=a) typ (in=b);
by id;
if a and b;
drop diag;
run;

proc export data=cnsranalys
outfile='/folders/myfolders/LungCancerDatasets/suranalys04.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

proc sort data=cnsranalys;
by id;
run;

data survival;
set suranalys(rename=(type=ctype)) cnsranalys(rename=(type=ctype));
by id;
keep id grp surtime event ctype sex diagage; 
run;

proc sort data=survival;
by id event;
run;

data survival;
set survival;
by id;
if ^missing(surtime);
if last.id;
run;

proc export data=survival
outfile='/folders/myfolders/LungCancerDatasets/newsurvival0.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

data survival1;
set survival;
if ctype="非小细胞肺癌";
run;

data survival2;
set survival;
if ctype="小细胞肺癌";
run;

data survival3;
set survival;
if grp="化疗（含铂类）";
run;

data survival4;
set survival;
if grp="乌苯美司+化疗（含铂类）";
run;

proc means data=survival;
run;

proc ttest data=survival;
class grp;
var diagage;
run;

proc freq data=survival;
tables sex*grp/fisher;
run;

proc freq data=survival;
tables ctype*grp/fisher;
run;

proc freq data=survival1;
tables event*grp;
run;

ods graphics on;
proc lifetest data=survival method=KM plots=survival (cb=hw test);
time surtime*event(0);
strata grp ctype;
run;

ods graphics on;
proc lifetest data=survival1 method=KM plots=survival (cb=hw test);
title "非小";
time surtime*event(0);
strata grp;
run;

ods graphics on;
proc lifetest data=survival2 method=KM plots=survival (cb=hw test) ;
title "小细胞肺癌";
time surtime*event(0);
strata grp;
run;

ods graphics on;
proc lifetest data=survival3 method=KM plots=survival (cb=hw test);
title "只使用化疗药";
time surtime*event(0);
strata ctype;
run;

ods graphics on;
proc lifetest data=survival4 method=KM plots=survival (cb=hw test) ;
title "使用乌苯美司+化疗药";
time surtime*event(0);
strata ctype;
run;

/*ods graphics on;
proc phreg data=coxph plots=survival;
title "Cox Model";
class grp (ref="化疗") sex (ref="男") surgery(ref="无") ;
model surtime*event(0)=grp age sex surgery/sle=0.05 sls=0.05 rl;
strata type;
run;*/

data survival1;
set survival;
if ctype="非小细胞肺癌";
run;

data survival2;
set survival;
if ctype="小细胞肺癌";
run;

ods graphics on;
proc lifetest data=survival method=KM plots=survival (cb=hw test);
time surtime*event(0);
strata grp ctype;
run;