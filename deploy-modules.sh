#!/usr/bin/env bash

sudo mkdir -p /var/lib/elasticsearch/
sudo chown $USER /var/lib/elasticsearch/


sudo mkdir -p /var/osquery/log
sudo chown $USER /var/osquery



systemctl --user start osquery.service
systemctl --user start elasticsearch.service
systemctl --user status elasticsearch.service
