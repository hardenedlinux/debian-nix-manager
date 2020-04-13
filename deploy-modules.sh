#!/usr/bin/env bash

sudo mkdir -p /var/lib/elasticsearch/
sudo chown $USER /var/lib/elasticsearch/


sudo mkdir -p /var/osquery/log
sudo chown $USER /var/osquery

sudo mkdir -p /run/postgresql/
sudo mkdir -p /var/db/postgresql
sudo chown $USER /var/db/postgresql
sudo chown $USER /run/postgresql
sudo mkdir /var/lib/zookeeper
sudo chown $USER /var/lib/zookeeper

systemctl --user start osquery.service
systemctl --user start elasticsearch.service
systemctl --user status elasticsearch.service
systemctl --user status postgresql.service
systemctl --user start  postgresql.service
