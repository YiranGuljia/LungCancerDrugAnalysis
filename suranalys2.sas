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
merge cnsr (in=a) medgrp (in=b);
by id;
if a and b;
drop grp2 grp3;
run;

data cnsranalys;
merge cnsrgrp (in=a) typ (in=b);
by id;
if a and b;
drop diag;
run;

proc export data=cnsranalys
outfile='/folders/myfolders/LungCancerDatasets/suranalys2.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

proc sort data=cnsranalys;
by id;
run;

data survival;
set suranalys(rename=(type=ctype)) cnsranalys(rename=(type=ctype));
by id;
keep id grp surtime event ctype; 
run;

proc export data=survival
outfile='/folders/myfolders/LungCancerDatasets/survival.xlsx'
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

ods graphics on;
proc lifetest data=survival method=KM;
time surtime*event(0);
strata grp;
run;