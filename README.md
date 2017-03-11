# snapcraft.yaml for etcd releases and master

This is a repo for etcd snapcraft; each directory corresponds to a release,
snapcraft will create a snap of that release if run in that directory.
etcd-master contains snapcraft.yaml to build a snap of upstream master.
Ultimately etcd-master should land on the upstream master branch for
automatic edge builds.

The ingest track snaps are to migrate data from classic Ubuntu / Debian etcd
packaging, with configuration in /etc/default/etcd and data in
/var/lib/etcd to the new snap location of /var/snap/etcd/ common and
current. Install the snap with --channel=ingest/stable then run etcd.ingest
before refreshing to channel=2.3/stable and validating the running and
strictly confined etcd. It is then possible to upgrade to etcd 3.0 and 3.1
by switching to the relevant tracks.

It is advisable to backup the cluster in advance of this procedure.

The whole cluster must successfully complete each version jump - in other
words, you must upgrade each member to the 2.3 track, and once the logs
indicate that the cluster has switched to 2.3 mode, you can start upgrading
the members to 3.0, and similarly then to 3.1 once the whole cluster is on
3.0.

So the process on a single node looks like this:

  sudo snap install etcd --channel=ingest/stable
  sudo etcd.ingest

If all has gone smoothly you should see a prompt to refresh to the 2.3
track. Also, you should see the appropriate configuration files and key
material in /var/snap/etcd/common and /var/snap/etcd/current

  sudo snap refresh etcd --channel=2.3/stable

Your logs should now reflect this member joining the cluster. If all looks
good, repeat the process on each member. When the final member is done you
should see a log entry confirming the update of the cluster to 2.3.

  sudo snap refresh etcd --channel=3.0/stable

Note that the 3.0 release of etcd changed the format of configuration to
YAML, and the launch wrapper in the etcd 3.0 snap will determine if this
migration needs to be done. If so you should havev a backup of the old 2.x
config in /var/snap/etcd/common and the new yaml config in that directory as
well. Logs should indicate the member joining the cluster.

Repeat on all members, and then the cluster should report being upgraded to
support 3.0 capabilities.

Before you move on to 3.1, though, please make another backup of the cluster.

In etcd 3.1 the semantics of certificate names and validation seem to have
been tightened appropriately. Existing certificates may fail to validate.
Nevertheless, you can upgrade to 3.1 with:

  sudo snap refresh etcd --channel=3.1/stable
