read -p "pls input drbd resource [vdb]: " drbd
pcs cluster cib drbd_cfg
pcs -f drbd_cfg resource create $drbd ocf:linbit:drbd drbd_resource=$drbd op monitor interval=60s
pcs -f drbd_cfg resource master clone$drbd $drbd master-max=2 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
pcs -f drbd_cfg resource show
pcs cluster cib-push drbd_cfg
drbdadm status $drbd
