{}:

''
  mkdir_authdir()
  {
      sudo chown $USER /var/log
      sudo chown $USER /var/cache
      sudo chown $USER /var/lib
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

      # sudo mkdir /var/lib/hydra
      # sudo chown $USER /var/lib/hydra
      sudo mkdir /nix/var/nix/gcroots/hydra
      sudo chown $USER /nix/var/nix/gcroots/hydra
  }

  start_service()
  {
      systemctl --user start osquery.service
      systemctl --user start elasticsearch-7x.service
      systemctl --user start logstash.service
      systemctl --user start postgresql.service
      systemctl --user start apache-kafka.service
      systemctl --user start zookeeper.service
      systemctl --user start netdata.service
      systemctl --user start kibana.service
      systemctl --user start elasticsearch.service
      systemctl --user start vast.service
  }

  enable_service()
  {
      systemctl --user enable osquery.service
      systemctl --user enable vast.service
      systemctl --user enable elasticsearch-7x.service
      systemctl --user enable logstash.service
      systemctl --user enable postgresql.service
      systemctl --user enable apache-kafka.service
      systemctl --user enable zookeeper.service
      systemctl --user enable netdata.service
      systemctl --user enable kibana.service
      systemctl --user enable elasticsearch.service
  }

  auth_path()
  {
  sudo chown $USER /var/lib
  sudo chown $USER /run/
  sudo chown $USER /var/cache
  sudo chown $USER /var/log
  sudo chown $USER /etc
  }
  check_service()
  {
      systemctl --user status apache-kafka.service
      systemctl --user status zookeeper.service
      systemctl --user status osquery.service
      systemctl --user status elasticsearch-7x.service
      systemctl --user status elasticsearch.service
      systemctl --user status hydra-server.service
      systemctl --user status postgresql.service
      systemctl --user status hydra-server.service
      systemctl --user status hydra-queue-runner.service
      systemctl --user status netdata.service
      systemctl --user status nix-serve.service
      systemctl --user status kibana.service
  }
  hydra_service()
  {
      systemctl --user start hydra-server.service
      systemctl --user start hydra-evaluator.service
      systemctl --user start hydra-queue-runner.service
      systemctl --user start nix-serve.service
  }
  while [ "$1" != "" ]; do
  case $1 in
      -f | --first) shift
                    mkdir_authdir
                    ;;
      -c | --check) shift
                    check_service
                    ;;
      -s | --start) shift
                    start_service
                    ;;
      -e | --enable) shift
                    enable_service
                    ;;
      -a | --auth) shift
                    auth_path
                    ;;
      -h | --hydra) shift
                    hydra_service
                    ;;
      * )
      shift
  esac
  done
''
