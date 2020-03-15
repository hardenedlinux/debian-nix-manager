{ config, pkgs, lib,  ...}:
with lib;
let
  ownpkgs_git = builtins.fetchTarball {
    url = "https://github.com/GTrunSec/nixpkgs/tarball/806fac5d109cdc6653c33a18924dac31ac477a2b";
    sha256 = "0b1aksy1070xh9wn7mwdgyz2hpfljr4jxs6qj90x7pnxj3m3p7a4";
  };

  ownpkgs = (import ownpkgs_git) { };
  vast = ownpkgs.callPackages ../pkgs/vast { };
  # vast = (import (ownpkgs.fetchgit {
  #   url = "https://github.com/tenzir/vast";
  #   rev = "295d0ff776026b4600df7360409f6830ebe0b0fe";
  #   deepClone = true;
  #   sha256 = "1nmh7wqqq6i72yam5g8a2nclcf3jchzd7s5vx5bx2jgsbllzclch";
  # }){});

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
    systemd.user.services."vast1" = {
      Unit = {
        After = [ "network.target"];
        description = "vast";
      };      
     
      Install = { WantedBy = [ "default.target" ]; };

      Service = {
        ExecStart = "${vast}/bin/vast -c ${configFile} start";
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
