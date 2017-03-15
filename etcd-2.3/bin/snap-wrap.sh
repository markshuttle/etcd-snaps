#! /bin/bash

# Prepare ETCD environment variables

# Use the system writable dir if run as root
if [[ $EUID -ne 0 ]]; then
  DATA_DIR=$SNAP_USER_DATA
  CONF_DIR=$SNAP_USER_COMMON
  echo "Running as user with data in $DATA_DIR"
else
  DATA_DIR=$SNAP_DATA
  CONF_DIR=$SNAP_COMMON
  echo "Running as system wih data in $DATA_DIR"
fi


# Migrate older config to new location
if [ -e $DATA_DIR/etcd.conf ]; then
  echo "Moving configuration to $CONF_DIR"
  mv $DATA_DIR/etcd.conf $CONF_DIR/
fi


# See if there is a configuration file
TARGET_CONF=$CONF_DIR/etcd.conf
FALLBACK_CONFIG="${TARGET_CONF}.2x"
if [ -e $TARGET_CONF ]; then
  # The desired configuration file is already in place
  echo "Configuration from $TARGET_CONF"
  set -o allexport
  . $TARGET_CONF
  set +o allexport
elif [ -e $FALLBACK_CONFIG ]; then
  # We've migrated and reverted to a 2.x series state
  echo "Configuration from fallback ${TARGET_CONF}.2x"
  set -o allexport
  . "${TARGET_CONF}.2x"
  set +o allexport
else
  echo "Please install config at $TARGET_CONF, then restart snap.etcd"
  exit 0
fi

# Only set the environment if the user has not done so
ETCD_NAME="${ETCD_NAME:=default}"
TARGET_DATA_DIR=$DATA_DIR/$ETCD_NAME.etcd
ETCD_DATA_DIR="${ETCD_DATA_DIR:=$TARGET_DATA_DIR}"


# Make sure it is exported not just set
export ETCD_NAME
export ETCD_DATA_DIR

exec $SNAP/bin/etcd "$@"

