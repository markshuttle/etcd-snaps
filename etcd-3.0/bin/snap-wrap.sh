#! /bin/bash

# Prepare ETCD environment variables

# Use the system writable dir if run as root
if [[ $EUID -ne 0 ]]; then
  DATA_DIR=$(dirname $SNAP_USER_DATA)/current
  CONF_DIR=$SNAP_USER_COMMON
  echo "Running as user with data in $DATA_DIR"
else
  DATA_DIR=$(dirname $SNAP_DATA)/current
  CONF_DIR=$SNAP_COMMON
  echo "Running as system with data in $DATA_DIR"
fi


# See if there is a configuration file
TARGET_CONF=$CONF_DIR/etcd.conf.yml
if [ -e $TARGET_CONF ]; then
  # The desired configuration file is already in place
  echo "Configuration from $TARGET_CONF"
else
  # Perhaps we need to migrate config to the new 3.x yaml format
  OLD_CONF=$CONF_DIR/etcd.conf
  if [ -e $OLD_CONF ]; then
    echo "Migrating config to 3.x yaml"
    . $OLD_CONF

    # Establish the member name, which defaults to hostname or 'default'
    ETCD_NAME="${ETCD_NAME:=$(hostname)}"
    ETCD_NAME="${ETCD_NAME:=default}"
    TARGET_DATA_DIR=$DATA_DIR/$ETCD_NAME.etcd
    # Determine target data dir
    ETCD_DATA_DIR="${ETCD_DATA_DIR:=$TARGET_DATA_DIR}"
    # XXX may need to set default values

    cat <<EOT > $TARGET_CONF.pre
# etcd config migrated from 2.x ENV-style to yaml.
# old config is in etcd.conf.2x

name: '$ETCD_NAME'
data-dir: '$ETCD_DATA_DIR'
wal-dir: '$ETCD_WAL_DIR'
snapshot-count: $ETCD_SNAPSHOT_COUNT
heartbeat-interval: $ETCD_HEARTBEAT_INTERVAL
election-timeout: $ETCD_ELECTION_TIMEOUT
listen-peer-urls: '$ETCD_LISTEN_PEER_URLS'
listen-client-urls: '$ETCD_LISTEN_CLIENT_URLS'
max-snapshots: $ETCD_MAX_SNAPSHOTS
max-wals: $ETCD_MAX_WALS
cors: '$ETCD_CORS'
advertise-client-urls: '$ETCD_ADVERTISE_CLIENT_URLS'
discovery: '$ETCD_DISCOVERY'
discovery-srv: '$ETCD_DISCOVERY_SRV'
discovery-fallback: '$ETCD_DISCOVERY_FALLBACK'
discovery-proxy: '$ETCD_DISCOVERY_PROXY'
strict-reconfig-check: $ETCD_STRICT_RECONFIG_CHECK
proxy: '$ETCD_PROXY'
proxy-failure-wait: $ETCD_PROXY_FAILURE_WAIT
proxy-refresh-interval: $ETCD_PROXY_REFRESH_INTERVAL
proxy-dial-timeout: $ETCD_PROXY_DIAL_TIMEOUT
proxy-write-timeout: $ETCD_PROXY_WRITE_TIMEOUT
proxy-read-timeout: $ETCD_PROXY_READ_TIMEOUT
client-transport-security:
  cert-file: '$ETCD_CERT_FILE'
  key-file: '$ETCD_KEY_FILE'
  client-cert-auth: $ETCD_CLIENT_CERT_AUTH
  trusted-ca-file: '$ETCD_TRUSTED_CA_FILE'
  auto-tls: false
peer-transport-security:
  cert-file: '$ETCD_PEER_CERT_FILE'
  key-file: '$ETCD_PEER_KEY_FILE'
  client-cert-auth: $ETCD_PEER_CLIENT_CERT_AUTH
  trusted-ca-file: '$ETCD_PEER_TRUSTED_CA_FILE'
  auto-tls: false
debug: $ETCD_DEBUG
log-package-levels: '$ETCD_LOG_PACKAGE_LEVELS'
EOT
  mv $TARGET_CONF.pre $TARGET_CONF
  mv $OLD_CONF $OLD_CONF.2x
  # XXX should move old conf to .old and say something to that effect
  fi
fi

if [ ! -e $TARGET_CONF ]; then
  echo "No config found, please create one at $TARGET_CONF"
  echo "See $SNAP/etcd.conf.yml.sample for an example."
  exit 0
fi

# Launch with the default config file
exec $SNAP/bin/etcd --config-file $TARGET_CONF "$@"

