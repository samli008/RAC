/usr/sbin/groupadd -g 501 oinstall
/usr/sbin/groupadd -g 502 dba
/usr/sbin/groupadd -g 503 oper
/usr/sbin/groupadd -g 504 asmadmin
/usr/sbin/groupadd -g 505 asmoper
/usr/sbin/groupadd -g 506 asmdba
/usr/sbin/useradd -g oinstall -G dba,asmdba,oper oracle
/usr/sbin/useradd -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid

echo "oracle" | passwd --stdin grid
echo "oracle" | passwd --stdin oracle

mkdir -p /oracle/app/grid
mkdir -p /oracle/app/11.2.0/grid
chown -R grid:oinstall /oracle

mkdir -p /oracle/app/oraInventory
chown -R grid:oinstall /oracle/app/oraInventory

mkdir -p /oracle/app/oracle
chown -R oracle:oinstall /oracle/app/oracle
chmod -R 775 /oracle

cat >> /etc/security/limits.conf <<EOF

#ORACLE SETTING
grid                 soft    nproc   2047 
grid                 hard    nproc   16384
grid                 soft    nofile  1024
grid                 hard    nofile  65536
grid   		     soft   stack    10240
grid   		     hard   stack    32768
oracle               soft    nproc   2047
oracle               hard    nproc   16384
oracle               soft    nofile  1024
oracle               hard    nofile  65536
oracle   	     soft   stack    10240
oracle  	     hard   stack    32768
EOF

cat > /etc/security/limits.d/90-nproc.conf <<EOF
* - nproc 16384
root  soft  nproc  unlimited
EOF

cat >> /etc/pam.d/login <<EOF
#ORACLE SETTING
session    required     pam_limits.so
EOF

cat >> /etc/sysctl.conf <<EOF
#ORACLE SETTING
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = 2147483648
kernel.shmall = 524288
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

cat > /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = 2147483648
kernel.shmall = 524288
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

sysctl -p

chkconfig ntpd off
mv /etc/ntp.conf /etc/ntp.conf.orig

cat >> /home/grid/.bash_profile <<EOF
PS1="[grid@`hostname`:"'/home/grid]$'
export PS1
umask 022
alias sqlplus="rlwrap sqlplus"
export TMP=/tmp
export LANG=en_US
export TMPDIR=/tmp
export ORACLE_HOSTNAME=$HOSTNAME
ORACLE_SID=+ASM1; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
ORACLE_BASE=/oracle/app/grid; export ORACLE_BASE
ORACLE_HOME=/oracle/app/11.2.0/grid; export ORACLE_HOME
NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"; export NLS_DATE_FORMAT
PATH=.:.:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/grid/bin:/home/grid/bin:/bin:/home/grid/bin:/oracle/app/11.2.0/grid/bin; export PATH
THREADS_FLAG=native; export THREADS_FLAG
if [ grid = "oracle" ] || [ grid = "grid" ]; then
        if [ /bin/bash = "/bin/ksh" ]; then
            ulimit -p 16384
              ulimit -n 65536
  else
   ulimit -u 16384 -n 65536
      fi
    umask 022
fi
EOF

cat >> /home/oracle/.bash_profile <<EOF
PS1="[oracle@`hostname`:"'/home/oracle]$'
alias sqlplus="rlwrap sqlplus"
alias rman="rlwrap rman"
export PS1
export TMP=/tmp
export LANG=en_US
export TMPDIR=/tmp
export ORACLE_HOSTNAME=$HOSTNAME
export ORACLE_UNQNAME=racdb
ORACLE_BASE=/oracle/app/oracle; export ORACLE_BASE
ORACLE_HOME=/oracle/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
ORACLE_SID=racdb1; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"; export NLS_DATE_FORMAT
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK;export NLS_LANG
PATH=.:.:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/oracle/bin:/home/oracle/bin:/product/11.2.0/db_1/bin:/bin:/home/oracle/bin:/oracle/app/oracle/product/11.2.0/db_1/bin:/product/11.2.0/db_1/bin; export PATH
THREADS_FLAG=native; export THREADS_FLAG
if [ oracle = "oracle" ] || [ oracle = "grid" ]; then
        if [ /bin/bash = "/bin/ksh" ]; then
            ulimit -p 16384
              ulimit -n 65536
  else
   ulimit -u 16384 -n 65536
      fi
    umask 022
fi
EOF

rpm -ivh kmod-oracleasm-2.0.6.rh1-3.el6.x86_64.rpm
rpm -ivh oracleasmlib-2.0.4-1.el6.x86_64.rpm
rpm -ivh oracleasm-support-2.1.8-1.el6.x86_64.rpm

/etc/init.d/oracleasm configure

export CVUQDISK_GRP=oinstall
rpm -ivh cvuqdisk-1.0.9-1.rpm
