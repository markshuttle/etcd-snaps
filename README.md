# snapcraft.yaml for etcd releases and master

This is a repo for etcd snapcraft; each directory corresponds to a release,
snapcraft will create a snap of that release if run in that directory.
etcd-master contains snapcraft.yaml to build a snap of upstream master.
Ultimately etcd-master should land on the upstream master branch for
automatic edge builds.
