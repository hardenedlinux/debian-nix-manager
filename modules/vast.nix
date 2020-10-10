{ config, pkgs, lib,  ...}:
with lib;
let
  cfg = config.services.vast;

  configFile =  pkgs.writeText "vast.conf" ''
  system {
      endpoint =  "${toString cfg.endpoint}";
  }
    '';
in
{
  options = {
    services.vast = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable vast endpoint
        '';
      };

      package = mkOption {
        type = types.package;
        defaultText = "";
        description = "The vast package.";
      };

      endpoint = mkOption {
        type = types.str;
        default = "localhost:4000";
        example = "localhost:4000";
        description = ''
              The host and port to listen at and connect to.
      '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.vast = {
      Unit = {
        After = [ "network.target"];
        description = "vast";
      };

      Install = { wantedBy = [ "multi-user.target" ];};

      Service = {
        ExecStart = "${cfg.package}/bin/vast --config=${configFile} start";
        ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
        KillMode = "control-group"; # upstream recommends process
        Restart = "always";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
 }
