# init centos6.x system with db01 script
echo "192.168.6.71 c05" >> /etc/hosts
sh db01

# install rlwrap for sqlplus
yum -y install gcc make readline readline-devel
tar zxvf rlwrap-0.42.tar.gz
cd rlwrap-0.42
./configure
make && make install

# unzip software
mkdir /soft
cd /soft
unzip p13390677_112040_Linux-x86-64_1of7.zip && unzip p13390677_112040_Linux-x86-64_2of7.zip

chown -R oracle:oinstall /soft
chown -R oracle:oinstall /oracle

su - oracle
cd /soft/database

./runInstaller -silent -ignoreSysPrereqs -showProgress -responseFile /home/oracle/db_install.rsp

1. /oracle/app/oracle/oraInventory/orainstRoot.sh
2. /oracle/app/oracle/product/11.2.0.4/db_1/root.sh

dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbName db01 -sysPassword oracle -systemPassword oracle


sqlplus "/as sysdba"
set line 200 pages 100
select instance_name,status,host_name from gv$instance;

select name from v$datafile;
select name from v$tablespace;
create tablespace liyang01 datafile '/oracle/app/oracle/oradata/db01/liyang01.dbf' size 20m;

drop tablespace liyang01 including contents and datafiles;

create user liyang profile "DEFAULT"
identified by liyang default tablespace liyang01
temporary tablespace temp
account unlock;

select * from all_users;
grant dba to liyang;
drop user liyang cascade;

conn liyang/liyang

create table t01
(
ID NUMBER(12),
C_DATE DATE
);

insert into t01 values(1,sysdate);
insert into t01 values(2,sysdate);
insert into t01 values(3,sysdate);
insert into t01 values(4,sysdate);

commit;

select * from t01
select table_name from tabs;
show user;
