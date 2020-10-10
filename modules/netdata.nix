{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.netdata;

  wrappedPlugins = pkgs.runCommand "wrapped-plugins" { preferLocalBuild = true; } ''
    mkdir -p $out/libexec/netdata/plugins.d
    ln -s /run/wrappers/bin/apps.plugin $out/libexec/netdata/plugins.d/apps.plugin
    ln -s /run/wrappers/bin/freeipmi.plugin $out/libexec/netdata/plugins.d/freeipmi.plugin
    ln -s /run/wrappers/bin/perf.plugin $out/libexec/netdata/plugins.d/perf.plugin
    ln -s /run/wrappers/bin/slabinfo.plugin $out/libexec/netdata/plugins.d/slabinfo.plugin
  '';

  PreShell = pkgs.writeScript "run-netdata" ''
    if [ ! -d "/var/lib/netdata" ];then
      mkdir -p /var/lib/netdata
      fi
    if [ ! -d "/var/log/netdata" ];then
      mkdir -p /var/log/netdata
      fi
    if [ ! -d "/etc/netdata" ];then
      mkdir -p /etc/netdata
      fi
    if [ ! -d "/var/cache/netdata" ];then
      mkdir -p /var/cache/netdata
      fi
  '';

  plugins = [
    "${cfg.package}/libexec/netdata/plugins.d"
    "${wrappedPlugins}/libexec/netdata/plugins.d"
  ] ++ cfg.extraPluginPaths;

  localConfig = {
    global = {
      "plugins directory" = concatStringsSep " " plugins;
      "bind to" = "127.0.0.1:19999";
    };
    web = {
      "web files owner" = "root";
      "web files group" = "root";
    };

  };
  mkConfig = generators.toINI {} (recursiveUpdate localConfig cfg.config);
  configFile = pkgs.writeText "netdata.conf" (if cfg.configText != null then cfg.configText else mkConfig);

  defaultUser = "netdata";

in {
  options = {
    services.netdata = {
      enable = mkEnableOption "netdata";

      package = mkOption {
        type = types.package;
        default = pkgs.netdata;
        defaultText = "pkgs.netdata";
        description = "Netdata package to use.";
      };

      user = mkOption {
        type = types.str;
        default = "netdata";
        description = "User account under which netdata runs.";
      };

      group = mkOption {
        type = types.str;
        default = "netdata";
        description = "Group under which netdata runs.";
      };

      configText = mkOption {
        type = types.nullOr types.lines;
        description = "Verbatim netdata.conf, cannot be combined with config.";
        default = null;
        example = ''
          [global]
          debug log = syslog
          access log = syslog
          error log = syslog
        '';
      };

      python = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable python-based plugins
          '';
        };
        extraPackages = mkOption {
          default = ps: [];
          defaultText = "ps: []";
          example = literalExample ''
            ps: [
              ps.psycopg2
              ps.docker
              ps.dnspython
            ]
          '';
          description = ''
            Extra python packages available at runtime
            to enable additional python plugins.
          '';
        };
      };

      extraPluginPaths = mkOption {
        type = types.listOf types.path;
        default = [ ];
        example = literalExample ''
          [ "/path/to/plugins.d" ]
        '';
        description = ''
          Extra paths to add to the netdata global "plugins directory"
          option.  Useful for when you want to include your own
          collection scripts.
          </para><para>
          Details about writing a custom netdata plugin are available at:
          <link xlink:href="https://docs.netdata.cloud/collectors/plugins.d/"/>
          </para><para>
          Cannot be combined with configText.
        '';
      };

      config = mkOption {
        type = types.attrsOf types.attrs;
        default = {};
        description = "netdata.conf configuration as nix attributes. cannot be combined with configText.";
        example = literalExample ''
          global = {
            "debug log" = "syslog";
            "access log" = "syslog";
            "error log" = "syslog";
          };
        '';
        };
      };
    };

  config = mkIf cfg.enable {
    assertions =
      [ { assertion = cfg.config != {} -> cfg.configText == null ;
          message = "Cannot specify both config and configText";
        }
      ];

    systemd.user.services.netdata = {
      Unit = {
      description = "Real time performance monitoring";
      after = [ "network.target" ];
      };
        Install = { wantedBy = [ "multi-user.target" ];};
      # path = (with pkgs; [ curl gawk which ]) ++ lib.optional cfg.python.enable
      #   (pkgs.python3.withPackages cfg.python.extraPackages);
      Service = {
        Environment="PYTHONPATH=${cfg.package}/libexec/netdata/python.d/python_modules";
        ExecStart = "${cfg.package}/bin/netdata -P /run/netdata/netdata.pid -D -c ${configFile}";
        ExecReload = "${pkgs.utillinux}/bin/kill -s HUP -s USR1 -s USR2 $MAINPID";
        ExecStartPre = ''
           ${pkgs.bash}/bin/bash ${PreShell}
         '';

        TimeoutStopSec = 60;
        # User and group
        # Runtime directory and mode
        RuntimeDirectory = "netdata";
        RuntimeDirectoryMode = "0755";
        # Performance
        LimitNOFILE = "30000";
      };
      };
    };
}
