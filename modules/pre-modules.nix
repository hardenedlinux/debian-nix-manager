{ config, lib, pkgs, ... }:
{
  config = with lib; mkMerge [
    (mkIf config.services.hydra.enable {
      home.activation.preRunHydra = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
     if [ ! -d "/var/lib/hydra" ];then
      mkdir -p /var/lib/hydra/
      fi
      '';
    })

    (mkIf config.services.zeek.enable {
      home.activation.preRunZeek = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
     if [ ! -d "/var/lib/zeek" ];then
      mkdir -p /var/lib/zeek/
      fi
      '';
    })

    (mkIf config.services.postgresql.enable {
      home.activation.preRunPostgresql = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/run/postgresql" ];then
      sudo mkdir -p /run/postgresql && sudo chown $USER /run/postgresql
      fi
      if [ ! -d "/var/lib/postgresql" ];then
      mkdir -p /var/lib/postgresql/
      fi
      '';
    })

    (mkIf config.services.nix-serve.enable {
      home.activation.preRunNix-serve= lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$HOME/.config/key" ];then
      mkdir -p $HOME/.config/key
      if [ ! -f "$HOME/.config/key/cache-pub-key.pem" ];then
      ## https://nixos.wiki/wiki/Binary_Cache
      ${pkgs.nix}/bin/nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem
      fi
     fi
      '';
    })

    (mkIf config.services.elasticsearch.enable {
      home.activation.preRunElasticsearch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/var/lib/elasticsearch" ];then
      mkdir -p /var/lib/elasticsearch/
      sudo mkdir -p /var/lib/elasticsearch/
      sudo chown $USER /var/lib/elasticsearch/
      fi
      '';
    })

    (mkIf config.services.logstash.enable {
      home.activation.preRunLogstash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/var/lib/logstash" ];then
      mkdir -p /var/lib/logstash/
      sudo mkdir -p /var/lib/logstash/
      sudo chown $USER /var/lib/logstash/
      fi
      '';
    })

    (mkIf config.services.vast.enable {
      home.activation.preRunVast = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
     # if [ ! -d "/var/lib/hydra" ];then
     #  mkdir -p /var/lib/hydra/
      '';
    })

    (mkIf config.services.netdata.enable {
      home.activation.preRunNetdata = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
     if [ ! -d "/var/lib/netdata" ];then
      mkdir -p /var/lib/netdata/
      fi
      '';
    })
  ];
}
