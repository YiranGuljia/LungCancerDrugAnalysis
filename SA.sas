FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/suranalys2.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.surv2;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/survival.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.survival;
	GETNAMES=YES;
RUN;

data survival;
set survival;
if ^missing(surtime);
run;

data coxph;
set surv1 (keep=id age sex surgery event surtime grp type)
surv2 (keep=id age sex surgery event surtime grp type);
run;

data survival1;
set survival;
if ctype="非小细胞肺癌";
if ^missing(surtime);
run;

data survival2;
set survival;
if ctype="小细胞肺癌";
if ^missing(surtime);
run;

data survival3;
set survival;
if grp="化疗";
if ^missing(surtime);
run;

data survival4;
set survival;
if grp="乌苯美司+化疗";
if ^missing(surtime);
run;

proc means data=survival4;
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

proc freq data=survival2;
tables event*grp;
run;

ods graphics on;
proc lifetest data=survival method=KM plots=survival /*(cb=hw test)*/;
time surtime*event(0);
strata grp ctype;
run;

ods graphics on;
proc lifetest data=survival1 method=KM plots=survival (cb=hw test);
time surtime*event(0);
strata grp;
run;

ods graphics on;
proc lifetest data=survival2 method=KM plots=survival (cb=hw test) ;
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

ods graphics on;
proc phreg data=coxph plots=survival;
title "Cox Model";
class grp (ref="化疗") sex (ref="男") surgery(ref="无") ;
model surtime*event(0)=grp age sex surgery/sle=0.05 sls=0.05 rl;
strata type;
*output out=report/method=pl;
run;
