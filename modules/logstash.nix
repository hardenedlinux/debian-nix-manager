{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.logstash;
  home_directory = builtins.getEnv "HOME";
  pluginPath = lib.concatStringsSep ":" cfg.plugins;
  havePluginPath = lib.length cfg.plugins > 0;
  ops = lib.optionalString;

  verbosityFlag = "--log.level " + cfg.logLevel;

  pluginsPath = "--path.plugins ${pluginPath}";

  logstashConf = pkgs.writeText "logstash.conf" ''
    input {
      ${cfg.inputConfig}
    }

    filter {
      ${cfg.filterConfig}
    }

    output {
      ${cfg.outputConfig}
    }
  '';

  logstashSettingsYml = pkgs.writeText "logstash.yml" cfg.extraSettings;

  logstashSettingsDir = pkgs.runCommand "logstash-settings"
    {
      inherit logstashSettingsYml;
      preferLocalBuild = true;
    } ''
    mkdir -p $out
    ln -s $logstashSettingsYml $out/logstash.yml
    cp ${cfg.package}/config/log4j2.properties $out/.
     sed -i "1ipath.logs = /var/lib/logstash/logs" $out/log4j2.properties
  '';

  PreShell = pkgs.writeScript "run-logstash" ''
    ${cfg.package}/bin/logstash \
    ${pluginsPath} \
    --path.config "${toString cfg.logstashConfDir}/*.conf" \
    --path.settings ${logstashSettingsDir} \
    --path.data ${cfg.dataDir}
  '';

in
{
  imports = [
    (mkRenamedOptionModule [ "services" "logstash" "address" ] [ "services" "logstash" "listenAddress" ])
    (mkRemovedOptionModule [ "services" "logstash" "enableWeb" ] "The web interface was removed from logstash")
  ];

  ###### interface

  options = {

    services.logstash = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable logstash.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.logstash;
        defaultText = "pkgs.logstash";
        example = literalExample "pkgs.logstash";
        description = "Logstash package to use.";
      };

      plugins = mkOption {
        type = types.listOf types.path;
        default = [ ];
        example = literalExample "[ pkgs.logstash-contrib ]";
        description = "The paths to find other logstash plugins in.";
      };

      logstashConfDir = mkOption {
        type = types.str;
        default = "${home_directory}/.config/nixpkgs/elk/zeek-logstash";
        description = ''
          A path to directory writable by logstash that it uses to sotre config files.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/logstash";
        description = ''
          A path to directory writable by logstash that it uses to store data.
          Plugins will also have access to this path.
        '';
      };

      logLevel = mkOption {
        type = types.enum [ "debug" "info" "warn" "error" "fatal" ];
        default = "warn";
        description = "Logging verbosity level.";
      };

      filterWorkers = mkOption {
        type = types.int;
        default = 1;
        description = "The quantity of filter workers to run.";
      };

      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address on which to start webserver.";
      };

      port = mkOption {
        type = types.str;
        default = "9292";
        description = "Port on which to start webserver.";
      };

      inputConfig = mkOption {
        type = types.lines;
        default = ''generator { }'';
        description = "Logstash input configuration.";
        example = ''
          # Read from journal
          pipe {
            command => "''${pkgs.systemd}/bin/journalctl -f -o json"
            type => "syslog" codec => json {}
          }
        '';
      };

      filterConfig = mkOption {
        type = types.lines;
        default = "";
        description = "logstash filter configuration.";
        example = ''
          if [type] == "syslog" {
            # Keep only relevant systemd fields
            # http://www.freedesktop.org/software/systemd/man/systemd.journal-fields.html
            prune {
              whitelist_names => [
                "type", "@timestamp", "@version",
                "MESSAGE", "PRIORITY", "SYSLOG_FACILITY"
              ]
            }
          }
        '';
      };

      outputConfig = mkOption {
        type = types.lines;
        default = ''stdout { codec => rubydebug }'';
        description = "Logstash output configuration.";
        example = ''
          redis { host => ["localhost"] data_type => "list" key => "logstash" codec => json }
          elasticsearch { }
        '';
      };

      extraSettings = mkOption {
        type = types.lines;
        default = "";
        description = "Extra Logstash settings in YAML format.";
        example = ''
          pipeline:
            batch:
              size: 125
              delay: 5
        '';
      };

    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.user.services.logstash = with pkgs; {
      Unit = {
        description = "Logstash Daemon";
      };
      Install = { WantedBy = [ "multi-user.target" ]; };
      #path = [ pkgs.bash ];
      Service = {
        Environment = "JAVA_HOME=${pkgs.jre}";
        ExecStart = ''
          ${pkgs.bash}/bin/bash ${PreShell}
        '';
      };
    };
  };
}
