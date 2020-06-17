{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.zeek;
  USER = builtins.getEnv "USER";
  zeek-oneshot = pkgs.writeScript "zeek-oneshot" ''
  /usr/bin/sudo ${cfg.package}/bin/zeekctl deploy
  if [ $? -eq 0 ]; then
  sleep infinity
else
  exit
fi
  '';
  StandaloneConfig = ''
  [zeek]
  type=standalone
  host=${cfg.listenAddress}
  interface=${cfg.interface}
  '';

  ClusterConfig =  ''
  [logger]
  type=logger
  host=localhost
  [manager]
  type=manager
  host=localhost

  [proxy-1]
  type=proxy
  host=localhost

  [worker-1]
  type=worker
  host=localhost
  interface=eth0

  [worker-2]
  type=worker
  host=localhost
  interface=eth0
  '';
  
  NodeConf = pkgs.writeText "node.cfg" (if cfg.standalone then  StandaloneConfig else cfg.extraConfig);
  NetworkConf = pkgs.writeText "networks.cfg" cfg.network;

  PreShell = pkgs.writeScript "Pre-runZeek" ''
    if [ ! -d "/var/lib/zeek/logs" ];then
      mkdir -p /var/lib/zeek/logs
      fi
    if [ ! -d "/var/lib/zeek/spool" ];then
      mkdir -p /var/lib/zeek/spool
      fi
    if [ ! -d "/var/lib/zeek/etc" ];then
      mkdir -p /var/lib/zeek/etc
      fi
    if [ ! -d "/var/lib/zeek/scripts" ];then
      mkdir -p /var/lib/zeek/scripts
      fi
    if [ ! -d "/var/lib/zeek/policy" ];then
      mkdir -p /var/lib/zeek/policy
      fi
   ln -sf ${NodeConf} /var/lib/zeek/etc/node.cfg
   ln -sf ${NetworkConf} /var/lib/zeek/etc/networks.cfg
   if [ ! -d "/var/lib/zeek/scripts/helpers" ];then
   cp -r ${cfg.package}/share/zeekctl/scripts/helpers /var/lib/zeek/scripts/
    cp -r ${cfg.package}/share/zeekctl/scripts/postprocessors /var/lib/zeek/scripts/
   fi
   cp -r ${pkgs.zeek}/share/zeek/site/local.zeek /var/lib/zeek/policy/
   ##https://github.com/dopheide-esnet/zeek-known-hosts-with-dns
   sed -i 's|@load protocols/conn/known-hosts|##@load protocols/conn/known-hosts|' /var/lib/zeek/policy/local.zeek

   for i in  run-zeek crash-diag         expire-logs        post-terminate     run-zeek-on-trace  stats-to-csv        check-config       expire-crash       make-archive-name  run-zeek           set-zeek-path             archive-log        delete-log     send-mail
   do
   ln -sf ${cfg.package}/share/zeekctl/scripts/$i /var/lib/zeek/scripts/
   done
   /usr/bin/sudo chmod 777 ${cfg.dataDir}/policy/local.zeek
   ${optionalString (cfg.privateScript != null)
     "echo \"${cfg.privateScript}\" >> ${cfg.dataDir}/policy/local.zeek"
    }
'';
in {

  options.services.zeek = {
    enable = mkOption {
      description = "Whether to enable zeek.";
      default = false;
      type = types.bool;
    };

    package = mkOption {
      description = "Zeek package to use.";
      default = "";
      defaultText = "zeek";
      type = types.package;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/zeek";
      description = ''
        Data directory for zeek. Do not change
      '';
    };
    standalone = mkOption {
      description = "Whether to enable zeek Standalone mode";
      default = true;
      type = types.bool;
    };

    privateScript = mkOption {
      description = "Zeek load private script path";
      default ="";
      type = types.str;
    };
        
    interface = mkOption {
      description = "Zeek listen address.";
      default = "eth0";
      type = types.str;
    };

    listenAddress = mkOption {
      description = "Zeek listen address.";
      default = "localhost";
      type = types.str;
    };

    network = mkOption {
      description = "Zeek network configuration.";
      default = ''
      # List of local networks in CIDR notation, optionally followed by a
      # descriptive tag.
      # For example, "10.0.0.0/8" or "fe80::/64" are valid prefixes.

      10.0.0.0/8          Private IP space
      172.16.0.0/12       Private IP space
      192.168.0.0/16      Private IP space
      '';
      type = types.str;
    };

    extraConfig = mkOption {
      type = types.lines;
      default = ClusterConfig;
      description = "Zeek cluster configuration.";
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.zeek = {
      Unit = {
        description = "Zeek Daemon";
        after = [ "network.target" ];
      };
      Install = { wantedBy = [ "multi-user.target" ];};
      Service = {
        Environment = [
          ''"INTERFACE=${cfg.interface}"''
        ];
        #ProtectSystem = "strict";
        ExecStart = ''
         ${pkgs.bash}/bin/bash ${zeek-oneshot}
         '';
        ExecReload = "${pkgs.bash}/bin/bash ${zeek-oneshot}";
        ExecStop = "/usr/bin/sudo ${cfg.package}/bin/zeekctl stop";
        ExecStartPre = ''
        ${pkgs.bash}/bin/bash ${PreShell}
       '';
      };
    };
  };
}
