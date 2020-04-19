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

# install grid on one node
yum -y install tigervnc-server
su - grid
vncserver :1
cd $ORACLE_HOME
unzip /home/grid/LINUX.X64_193000_grid_home.zip
./gridSetup.sh

