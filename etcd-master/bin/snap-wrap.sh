#! /bin/bash

# Prepare ETCD environment variables

# Use the system writable dir if run as root
if [[ $EUID -ne 0 ]]; then
  TARGET_DATA_DIR=$SNAP_USER_DATA/data
  TARGET_CONF=$SNAP_USER_DATA/etcd.conf.yml
else
  TARGET_DATA_DIR=$SNAP_DATA/data
  TARGET_CONF=$SNAP_DATA/etcd.conf.yml
fi

if [ -e $TARGET_CONF ]; then
  # The desired configuration file is already in place
  echo "Configuration exists"
else
  cp $SNAP/etcd.conf.yml.sample $TARGET_CONF
  echo "Creating fresh config at $TARGET_CONF"
fi

# Only set the environment if the user has not done so
ETCD_DATA_DIR="${ETCD_DATA_DIR:=$TARGET_DATA_DIR}"

# Make sure it is exported not just set
export ETCD_DATA_DIR

exec $SNAP/bin/etcd "$@"

