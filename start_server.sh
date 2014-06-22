#!/bin/bash
# Don't use this unless you know what this script does exactly!

# The script has been developed for OpenStack Havana and also works on
# Icehouse, but requires neutron for the network stack. If you still use
# nova for networking, please adapt the script.

# Config
STATIC_FIXED_IP="192.168.1.2"
STATIC_FLOATING_IP="10.102.8.109"
SERVER_NAME="server-01"
VOL_ROOT_NAME="sever-01-root"
NETWORK_NAME="virtual_infrastructure_network"
NOVA_KEY="infrastructure"
METADATA='--meta ansible_host_vars=dns_server_for_domains->v.clusterb.centerdevice.local,infrastructure.v.clusterb.centerdevice.local --meta ansible_host_groups=admin_v_infrastructure,apt_repos'
IMAGE_NAME="Ubuntu 14.04 x64 Server"

### No changes below this line ###

# Check for OpenStack credentials
nova list > /dev/null
if [ $? -ne 0 ]; then
   echo OS_ credentials not set. Aborting.
   exit -1
fi

# Boot Instance
IMAGE_ID=$(nova image-list | grep "$IMAGE_NAME" | awk '{ print $2 }'); echo IMAGE_ID: $IMAGE_ID
nova volume-create --image-id $IMAGE_ID --display-name $VOL_ROOT_NAME --display-description "Root Volume for Server $SERVER_NAME" 5
VOL_ROOT_ID=$(nova volume-list | grep $VOL_ROOT_NAME | awk '{print $2}'); echo VOL_ROOT_ID: $VOL_ROOT_ID
NET_ID=$(neutron net-list | grep "$NETWORK_NAME" | awk '{print $2}'); echo NET_ID: $NET_ID
nova boot --flavor m1.medium --nic net-id=${NET_ID},v4-fixed-ip=${STATIC_FIXED_IP} --key-name $NOVA_KEY --block-device-mapping vda=${VOL_ROOT_ID}:::1 $METADATA $SERVER_NAME

# Wait for instance to become ready
echo Waiting 10 sec for nova instance to become available
sleep 10

# Create Floating IPs
#neutron floatingip-create ext-net

# Assign Floating IP
FLOATINGIP_ID=$(neutron floatingip-list | grep ${STATIC_FLOATING_IP} | awk '{print $2}'); echo FLOATINGIP_ID: $FLOATINGIP_ID
PORT_ID=$(nova interface-list $SERVER_NAME | grep ACTIVE | awk '{ print $4 }'); echo PORT_ID: $PORT_ID
neutron floatingip-associate $FLOATINGIP_ID $PORT_ID

