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
