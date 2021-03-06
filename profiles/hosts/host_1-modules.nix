{ config, pkgs, lib, ... }:
let
  hydra-pkgs = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/tarball/ed113c9bd58542d9a7782ec128272bf4d294bd1d") { };
in
{
  config = with lib; mkMerge [
    (mkIf (config.home.username == config.host_1.username) {
      services.zeek = {
        enable = true;
        standalone = true;
        package = pkgs.zeek;
        interface = config.host_1.interface_1.name;
        listenAddress = config.host_1.interface_1.ip;
        #Tue Jun 16 11:57:31 HKT 2020'
        privateScript = ''
          @load ${config.home.homeDirectory}/.zeek-script
        '';
      };

      services.netdata = {
        enable = true;
      };

      services.zookeeper = {
        enable = true;
      };


      services.apache-kafka = {
        enable = true;
        #brokerId=1;
        logDirs = [ "/var/lib/kafka/log" ];
      };


      services.hydra = {
        enable = true;
        listenHost = config.host_1.interface_1.ip;
        port = 8300;
        package = hydra-pkgs.hydra-unstable.overrideAttrs (old: rec {
          preConfigure = ''
            sed -i 's|evalSettings.restrictEval = true;|evalSettings.restrictEval = false;|' src/hydra-eval-jobs/hydra-eval-jobs.cc
          '';
        });
        max_job = 24;
        hydraURL = "http://${config.host_1.interface_1.ip}";
        notificationSender = "gtrun@hardenedlinux.org";
        useSubstitutes = true;
        logo = "${config.home.homeDirectory}/.config/nixpkgs/misc/img/logo_no_background_color_white.png";
      };



      services.vast = {
        enable = true;
        endpoint = "localhost:4000";
        package = pkgs.vast;
        #db-directory = "./vast/vast.db";
        #log-directory = "./vast/vast.log";
      };

      services.osquery = {
        enable = true;
      };


      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_11;
        dataDir = "/var/db/postgresql/11";
      };


      services.nix-serve = {
        enable = true;
        port = 8301;
        package = pkgs.nix-serve;
        bindAddress = config.host_1.interface_1.ip;
        secretKeyFile = "${config.home.homeDirectory}/.config/key/cache-priv-key.pem";
      };
    })
  ];
}
