# config hosts
192.168.20.131 ora1
192.168.20.132 ora2

192.168.100.131 ora1prv
192.168.100.132 ora2prv

192.168.20.133 ora1vip
192.168.20.134 ora2vip

192.168.20.135 scanvip

# install environment both nodes
yum -y install oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm
rpm -ivh cvuqdisk-1.0.10-1.rpm

# install Desktop
yum -y groups install "GNOME Desktop"

# modify user and group both nodes
userdel -r oracle
userdel -r grid
groupdel oinstall
groupdel dba
groupadd -g 5001 oinstall
groupadd -g 5002 dba
groupadd -g 5003 asmdba
groupadd -g 5004 asmoper
groupadd -g 5005 asmadmin
useradd -u 6001 -g oinstall -G asmadmin,asmdba,asmoper grid
useradd -u 6002 -g oinstall -G dba,asmadmin oracle

passwd oracle
passwd grid

# create install dir both nodes
mkdir /opt/oracle
mkdir -p /opt/oracle/app/grid
mkdir -p /opt/oracle/app/19c/grid
chown -R grid:oinstall /opt/oracle
mkdir -p /opt/oracle/app/oraInventory
chown -R grid:oinstall /opt/oracle/app/oraInventory
mkdir -p /opt/oracle/app/oracle/product/19c/dbhome_1
chown -R oracle:oinstall /opt/oracle/app/oracle
chmod -R 775 /opt/oracle

# grid env config both nodes
su - grid
vi ~/.bash_profile
umask 022
export ORACLE_SID=+ASM1
export ORACLE_BASE=/opt/oracle/app/grid
export ORACLE_HOME=/opt/oracle/app/19c/grid
export PATH=.:$PATH:$HOME/bin:$ORACLE_HOME/bin

source ~/.bash_profile
env |grep ORACLE

# oracle env config both nodes
su - oracle
vi ~/.bash_profile
umask 022
export ORACLE_BASE=/opt/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19c/dbhome_1
export ORACLE_UNQNAME=oracledb
export ORACLE_SID=oracledb1
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=.:$PATH:$HOME/bin:$ORACLE_HOME/bin

source ~/.bash_profile
env |grep ORACLE

# prepare ASM disk on both nodes
chown grid:oinstall /dev/drbd*

# install grid on one node
systemctl set-default graphical
systemctl set-default multi-user
yum -y install tigervnc-server
su - grid
vncserver :1
cd $ORACLE_HOME
unzip /home/grid/LINUX.X64_193000_grid_home.zip
./oui/prov/resources/scripts/sshUserSetup.sh -user grid -hosts "ora1 ora2" -advanced -noPromptPassphrase
./gridSetup.sh

# grid check
su - grid
ocrcheck
crsctl query css votedisk
crsctl status res -t
crs_stat -t
lsnrctl status
asmcmd lsdg 

sqlplus "/as sysasm"
desc v$asm_diskgroup;
select NAME,TOTAL_MB,FREE_MB from v$asm_diskgroup;

create diskgroup DGDATA01 external redundancy disk '/dev/iscsi/asm-data';
alter diskgroup DGDATA01 mount;

# install oracle
su - oracle
cd $ORACLE_HOME
unzip /home/oracle/LINUX.X64_193000_db_home.zip
./oui/prov/resources/scripts/sshUserSetup.sh -user oracle -hosts "ora1 ora2" -advanced -noPromptPassphrase
./runInstaller

# create database
## check oracle dir permission as root on both nodes
cd /opt/oracle/app/oracle/product/19c/dbhome_1/bin
ll -d oracle
chown oracle:asmadmin oracle
chmod 6751 oracle
/opt/oracle/app/19c/grid/bin/crsctl stop crs
/opt/oracle/app/19c/grid/bin/crsctl start crs
/opt/oracle/app/19c/grid/bin/crsctl check crs

su - oracle
dbca

# operation RAC database

sqlplus "/as sysdba"
set line 200 pages 100
select instance_name,status,host_name from gv$instance;
INSTANCE_NAME	 STATUS       HOST_NAME
---------------- ------------ ----------------------------------------------------------------
oracledb1		 OPEN	      ora1
oracledb2		 OPEN	      ora2

create tablespace liyang01
logging
datafile '+DGDATA01/racdb/datafile/liyang01.ora' size 10M autoextend
on next 10240k extent management local segment space
management auto;

select name from v$tablespace;

select name from v$datafile;

drop tablespace liyang01 including contents and datafiles;

create user liyang profile "DEFAULT"
identified by liyang default tablespace liyang01
temporary tablespace temp
account unlock;

select * from all_users;
s
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
