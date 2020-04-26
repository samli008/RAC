# drbd reource for oracle rac ASM
read -p "pls input drbd resource [drbd0]: " drbd
pcs cluster cib drbd_cfg
pcs -f drbd_cfg resource create $drbd ocf:linbit:drbd drbd_resource=$drbd op monitor interval=60s
pcs -f drbd_cfg resource master clone$drbd $drbd master-max=2 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
pcs -f drbd_cfg resource show
pcs cluster cib-push drbd_cfg
drbdadm status $drbd

# config pcs stonith on kvm-guest-vm
yum -y install fence-virt
mkdir -p /etc/cluster
echo fecb9e62cbcf4e54dcfb > /etc/cluster/fence_xvm.key

# view vm list on kvm-guset-vm, must need vm-bridge has ip address
fence_xvm -o list

pcs property set stonith-enabled=true

pcs stonith create fence1 fence_xvm multicast_address=225.0.0.12
pcs stonith create fence2 fence_xvm multicast_address=225.0.0.12

pcs stonith show
pcs stonith fence rac2
