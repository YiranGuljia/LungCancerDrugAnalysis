FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/habit.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.habit;
	GETNAMES=YES;
RUN;

data smkalc;
set habit;
if smoking="0年" then smk="不吸烟";
else if smoking="年" then smk="不吸烟";
else smk="吸烟";
if alcohol="0年" then alc="不饮酒";
else if alcohol="年" then alc="不饮酒";
else alc="饮酒";
keep id smk alc;
run;

proc sort data=smkalc nodupkey;
by id smk alc;
run;

data smkalc;
set smkalc;
by id;
if last.id;
run;

proc export data=smkalc
outfile='/folders/myfolders/LungCancerDatasets/smkalc.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/*******************************************************************/

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
set medgrpx (where=(grp1="化疗类"));
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

data medgrp6;
set medgrpx (where=(grp1="铂类"));
grp7=grp1;
keep id grp7;
run;

data medgrpnew;
merge medgrp1 (in=a) medgrp2 (in=b)
medgrp3 (in=c) medgrp4 (in=d) 
medgrp5 (in=e) medgrp6 (in=f);
by id;
if a and b and f and not c and not d and not e then grp="乌苯美司+化疗（含铂类）";
else if f and not a and not b and not c and not d and not e then grp="仅铂类化疗";
else if b and not c and not d and not e and not a and not f then grp="非铂类化疗";
else if b and f and not a and not c and not d and not e then grp="化疗（含铂类）";
else if c and not a and not b and not f and not d and not e then grp="仅靶向药";
else if c and f and not a and not b and not d and not e then grp="靶向药+铂类化疗";
else if c and b and not a and not d and not e and not f then grp="靶向药+非铂类化疗";
else if c and b and f and not a and not d and not e then grp="靶向药+化疗（含铂类）";
else if a and not b and not c and not d and not e and not f then grp="仅乌苯美司";
else if a and f and not b and not c and not d and not e then grp="乌苯美司+铂类化疗";
else if a and b and not c and not d and not e and not f then grp="乌苯美司+非铂类化疗";
else grp="其他复合疗法";
if missing(grp) then delete;
run;

proc sort data=medgrpnew;
by id;
run;

data medgrpn;
set medgrpnew;
by id;
if first.id;
keep id grp;
run;

proc export data=medgrpn
outfile='/folders/myfolders/LungCancerDatasets/medtreat.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/*****************************************************************************/

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate07.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt7;
	GETNAMES=YES;
RUN;

data bmi;
set plt7;
bmi=weight/((height/100)**2);
run;

proc sort data=bmi;
by id bmi;
run;

data bmi;
set bmi;
by id;
if last.id;
keep id bmi;
run;

proc export data=bmi
outfile='/folders/myfolders/LungCancerDatasets/bmi.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/*******************************************************************/

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate03.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt3;
	GETNAMES=YES;
RUN;

data surg;
set plt3;
keep id surgery;
run;

proc sort data=surg nodupkey;
by id;
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate13.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt13;
	GETNAMES=YES;
RUN;

data surglb;
set plt13;
keep id surgtyp;
if ^missing(id);
run;

proc sort data=surglb nodupkey;
by id surgtyp;
run;

data surgb;
set surglb;
by id;
if first.id;
run;

data surgy;
merge surgb surg;
by id;
if surgery="无" then surgtyp="未手术";
if ^missing(surgery);
run;

data surgy;
set surgy;
if missing(surgtyp) then surgtyp="非肺全切";
run;

proc export data=surgy
outfile='/folders/myfolders/LungCancerDatasets/surgy.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/***************************************************************************************/
FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate12.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt12;
	GETNAMES=No;
RUN;

data fm;
set plt12 (rename=(B=id C=heredity));
by id;
if ^missing(A);
if first.id;
keep id heredity;
run;

proc export data=fm
outfile='/folders/myfolders/LungCancerDatasets/famy.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/*******************************************************************************/

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate05.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt5;
	GETNAMES=Yes;
RUN;

data tn;
set plt5;
if ^missing(size);
run;

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/plate05add.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.plt05;
	GETNAMES=Yes;
RUN;

data typ;
set plt05 (drop=test);
length type$30;
if linai="鳞癌" and xianai="腺癌" then type="腺鳞均见";
else if linai="鳞癌" and missing(xianai) then type="鳞癌";
else if xianai="腺癌" and missing(linai) then type="腺癌";
length dft$30;
if gfenh="高分化" and missing(dfenh) and missing(zfenh) then dft="高分化";
else if zfenh="中分化" and missing(dfenh)  then dft="中分化";
else if dfenh="低分化" then dft="低分化";
run;

proc sort data=typ;
by id type dft;
run;

data typf;
set typ;
by id;
if last.id;
keep id type dft;
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

data typee;
set typex (in=a) typef (in=b) ;
if b then type="其他非小细胞肺癌";
if a then type="小细胞肺癌";
proc sort;
by id;
run;

data alltyp;
merge typee typf (rename=(type=typnam));
by id;
length typname$30;
if typnam="腺鳞均见" or typnam="腺癌" or typnam="鳞癌" then typname=typnam;
else typname=type;
if ^missing(typname);
keep id dft typname;
run;

proc export data=alltyp
outfile='/folders/myfolders/LungCancerDatasets/alltyp.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/************************************************************************/

FILENAME REFFILE '/folders/myfolders/LungCancerDatasets/size.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.sz;
	GETNAMES=YES;
RUN;

proc sort data=sz;
by id;
run;

data size;
set sz;
by id;
if size_1<3 then t="T1";
else if size_1>=3 and size_1<5 then t="T2";
else if size_1>=5 and size_1<7 then t="T3";
else if size_1>=7 then t="T4";
if size_1>15 then delete;
run;

data size;
merge size (in=a) plt05;
by id;
if a;
if index(test,"原位")>0 then t='T0';
keep id test t;
run;

proc sort data=size;
by id t;
run;

data size;
set size;
by id;
if last.id;
run;

proc sql;
create table nsize as 
select Test,ID from plt05
where Test contains '未见';

create table zsize as
select Test,ID from plt05
where Test contains '转移';

create table ksize as
select id from zsize
except select id from nsize;
quit;

proc sort data=plt05;
by id;
run;

data ntmsize;
merge ksize (in=a) zsize(in=b);
by id;
if a;
run;

proc sql;
create table sizen31 as 
select Test,ID from ntmsize
where Test contains '锁骨';
create table sizen32 as 
select Test,ID from ntmsize
where Test contains '右颈';
create table sizen33 as 
select Test,ID from ntmsize
where Test contains '左颈';
quit;

proc sql;
create table sizen21 as 
select Test,ID from ntmsize
where Test contains '主动脉';
create table sizen22 as 
select Test,ID from ntmsize
where Test contains '食管' ;
create table sizen23 as 
select Test,ID from ntmsize
where Test contains '肺韧带' ;
create table sizen24 as 
select Test,ID from ntmsize
where Test contains '隆突下' ;
quit;

data sizen2;
set sizen21 sizen22 sizen23 sizen24;
by id;
n="N2";
run;

data sizen3;
set sizen31 sizen32 sizen33;
by id;
n="N3";
run;

proc sql;
create table tmp as 
select Test,ID from ntmsize
where Test contains '淋巴结';
create table tmpsize as
select id from tmp
except select id from sizen2;
create table tpsize as
select id from tmpsize
except select id from sizen3;
quit;

data sizen1;
merge tpsize (in=a) ntmsize (in=b);
by id;
if a;
n="N1";
run;

data sizenx;
set sizen1 sizen2 sizen3;
by id;
run;

proc sort data=sizenx;
by id n;
run;

data sizenx;
set sizenx;
by id;
if last.id;
run;

data ntmfinal;
merge sizenx size;
by id;
m="M0";
if missing(n) then n="N0";
keep test id n t m;
run;

proc export data=ntmfinal
outfile='/folders/myfolders/LungCancerDatasets/ntm.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;

/********************************************************************/
data covr;
merge smkalc medgrpn bmi surgy fm alltyp ntmfinal;
by id;
drop test;
run;

proc export data=covr
outfile='/folders/myfolders/LungCancerDatasets/covr.xlsx'
dbms=xlsx replace;
sheet='sheet1';
run;