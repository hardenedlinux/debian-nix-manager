{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.vast;
  PreShell = pkgs.writeScript "check-vast-pid" ''
    if [ -f "${config.home.homeDirectory}/vast.db/pid.lock" ]; then
          rm -rf ${config.home.homeDirectory}/vast.db/pid.lock
    fi
  '';
  configFile = pkgs.writeText "vast.conf" (
    builtins.toJSON {
      vast = {
        endpoint = "${toString cfg.endpoint}";
      };
    });
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
        After = [ "network.target" ];
        description = "vast";
      };

      Install = { WantedBy = [ "multi-user.target" ]; };

      Service = {
        ExecStart = "${cfg.package}/bin/vast --config=${configFile} start";
        ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash ${PreShell}
        '';
        KillMode = "control-group"; # upstream recommends process
        Restart = "always";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
}
