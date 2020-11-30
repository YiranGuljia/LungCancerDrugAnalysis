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
merge eventtime (in=a) typ (in=b) ;
by id;
if a and b;
drop diag;
run;

proc export data=suranalys
outfile='/folders/myfolders/LungCancerDatasets/grpanlys.xlsx'
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


data cnsranalys;
merge cnsr (in=a) typ (in=b);
by id;
if a and b;
drop diag;
run;

proc export data=cnsranalys
outfile='/folders/myfolders/LungCancerDatasets/grpanalys1.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

proc sort data=cnsranalys;
by id;
run;

data survival;
set suranalys(rename=(type=ctype)) cnsranalys(rename=(type=ctype));
by id;
keep id surtime event ctype sex diagage; 
run;

proc sort data=survival;
by id event;
run;

data survival;
set survival;
by id;
if ^missing(surtime) & surtime>0;
if last.id;
run;

proc export data=survival
outfile='/folders/myfolders/LungCancerDatasets/ngrpsurvival.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

ods graphics on;
proc lifetest data=survival method=KM plots=survival (cb=hw test);
time surtime*event(0);
strata ctype;
run;
