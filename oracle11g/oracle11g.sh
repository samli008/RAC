# init centos6.x system with db01 script
echo "192.168.6.43 c61" >> /etc/hosts
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
