{ config, pkgs, lib,  ...}:

with builtins;
with lib;

let
  cfg = config.services.osquery;
  home_directory = builtins.getEnv "HOME";
  osuqerycfg = "${home_directory}/.osquery/osquery.conf";
  osquery = pkgs.callPackage ../../pkgs/osquery { };
in

{
  options = {

    services.osquery = {

      enable = mkEnableOption "osquery";

      loggerPath = mkOption {
        type = types.path;
        description = "Base directory used for logging.";
        default = "/var/osquery/log";
      };

      pidfile = mkOption {
        type = types.path;
        description = "Path used for pid file.";
        default = "/var/osquery/osqueryd.pidfile";
      };

      utc = mkOption {
        type = types.bool;
        description = "Attempt to convert all UNIX calendar times to UTC.";
        default = true;
      };

      databasePath = mkOption {
        type = types.path;
        description = "Path used for database file.";
        default = "/var/osquery/osquery.db";
      };
      extensionsPath = mkOption {
        type = types.path;
        description = "Path used for extensions_socket file";
        default = "/var/osquery/osquery.em";
      };
      extraConfig = mkOption {
        type = types.attrs // {
          merge = loc: foldl' (res: def: recursiveUpdate res def.value) {};
        };
        description = "Extra config to be recursively merged into the JSON config file.";
        default = { };
      };
    };

  };

  config = mkIf cfg.enable {
   home.file.".osquery/osquery.conf".text = toJSON (
      recursiveUpdate { 
        options = {
          config_plugin = "filesystem";
          logger_plugin = "filesystem";
          logger_path = cfg.loggerPath;
          database_path = cfg.databasePath;
          utc = cfg.utc;
        };
      } cfg.extraConfig
    );

    systemd.user.services.osquery = {
      Unit = {
        after = [ "network.target" "syslog.service" ];
        description = "The osquery Daemon";
      };

      Install = { WantedBy = [ "multi-user.target" ];};

      Service = {
        TimeoutStartSec = 0;
        ExecStart = "${osquery}/bin/osqueryd --database_path ${escapeShellArg cfg.databasePath}  --logger_path ${escapeShellArg cfg.loggerPath} --pidfile ${escapeShellArg cfg.pidfile} --database_path ${escapeShellArg cfg.databasePath} --extensions_socket  ${escapeShellArg cfg.extensionsPath} --config_path ${escapeShellArg osuqerycfg}";
        Restart = "always";
      };
    };
  };
}
