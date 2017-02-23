#!/bin/bash
set -ex
/usr/local/oozie-4.1.0/bin/oozie-setup.sh sharelib create -fs hdfs://hdfs-namenode:9000
/usr/local/oozie-4.1.0/bin/oozied.sh run
