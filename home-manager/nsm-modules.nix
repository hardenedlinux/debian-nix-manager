{config, pkgs, lib, ...}:
let
  home_directory = builtins.getEnv "HOME";
  hydra-pkgs = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/tarball/a18eaa7b93a05657b64a386c7f535e3ea25ec77a"){};
in
{
  imports = [
    ../modules/vast.nix
    ../modules/osquery
    ../modules/elastic.nix
    ../modules/postgresql.nix
    ../modules/nix-serve.nix
    ../modules/hydra.nix
    ../modules/zookeeper.nix
    ../modules/apache-kakfa.nix
    ../modules/kibana.nix
    ../modules/logstash.nix
    ../modules/netdata.nix
    ../modules/zeek.nix
    ../elk
  ];

  home.packages = with pkgs; [
    vast
    pf-ring
    #emacs eaf
    lxqt.qtermwidget
    (python3.withPackages (pkgs: with pkgs; [
      # rl algorithms
      dbus
      qrcode
      pyqt5
      pymupdf
      xlib
      grip
      pyqtwebengine
      pyinotify

      ##owner
    ]))
    
    # (emacsPackages.emacsWithPackages (with pkgs.emacsPackagesNg; [
    #   emacs-libvterm
    # ]))
    wakatime
    go
    nodejs
    tcpreplay
    bat
    suricata
    (zeek.override{ KafkaPlugin = true; PostgresqlPlugin = true;})
  ];

  services.zeek = {
    enable = true;
    standalone = true;
    interface = "enp0s3";
    listenAddress = "localhost";
    package = pkgs.zeek.override{ KafkaPlugin = true; PostgresqlPlugin = true; };
    # privateScript = ''
    # @load ${config.home.homeDirectory}/.zeek-script
    # '';
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
    logDirs = ["/var/lib/kafka/log"];
  };

  
  services.hydra = {
    enable = true;
    listenHost = "192.168.217.10";
    port = 8300;
    package = hydra-pkgs.hydra-unstable;
    max_job = 24;
    hydraURL = "http://192.168.216.10";
    notificationSender = "gtrun@hardenedlinux.org";
    useSubstitutes = true;
    logo = "${home_directory}/.config/nixpkgs/img/logo_no_background_color_white.png";
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
    package = pkgs.postgresql_11 ;
    dataDir = "/var/db/postgresql/11";
  };


  services.nix-serve = {
    enable = true;
    port = 8301;
    package = pkgs.nix-serve;
    bindAddress = "192.168.217.10";
    secretKeyFile = "${home_directory}/.config/key/cache-priv-key.pem";
  };
}
