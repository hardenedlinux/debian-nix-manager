#!/usr/bin/env bash
# Loop until all parameters are used up
mkdir_authdir()
{
    sudo chown $USER /var/log
    sudo chown $USER /var/cache
    sudo chown $USER /etc
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

    sudo mkdir /var/lib/kibana
    sudo chown $USER /var/lib/kibana

}

start_servie()
{
    systemctl --user start osquery.service
    systemctl --user start elasticsearch.service
    systemctl --user start elasticsearch.service
    systemctl --user start postgresql.service
    systemctl --user start netdata.service
    systemctl --user start nix-serve.service
    systemctl --user start  kibana..service
}

check_service()
{
    systemctl --user status osquery.service
    systemctl --user status elasticsearch.service
    systemctl --user status hydra-server.service
    systemctl --user status postgresql.service
    systemctl --user status hydra-server.service
    systemctl --user status hydra-queue-runner.service
    systemctl --user status netdata.service
    systemctl --user status nix-serve.service
    systemctl --user status kibana.service
}
while [ "$1" != "" ]; do
case $1 in
    -f | --first) shift
                  mkdir_authdir
                  ;;
    -c | --check) shift
                  check_service
                  ;;
    * )
    shift
esac
done

