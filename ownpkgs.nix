{config, pkgs, lib, ...}:
let
  nixpkgs = (import <nixpkgs> { config.allowUnfree = true; config.ignoreCollisions = true;});
  unstable = (import <unstable> { });
  home_directory = builtins.getEnv "HOME";
  ownpkgs_git = builtins.fetchTarball {
    url = "https://github.com/GTrunSec/nixpkgs/tarball/39247f8d04c04b3ee629a1f85aeedd582bf41cac";
     sha256 = "1q7asvk73w7287d2ghgya2hnvn01szh65n8xczk4x2b169c5rfv0";
  };

  ownpkgs = (import ownpkgs_git) { };
  zeek = pkgs.callPackage ./pkgs/zeek { };
  vast = ownpkgs.callPackage ./pkgs/vast { };
  pf-ring = ownpkgs.callPackage ./pkgs/network/pf_ring.nix { };

in
{
  imports = [
    ./modules/vast.nix
    ./modules/osquery
    ./modules/elastic.nix
    ./modules/postgresql.nix
    ./modules/nix-serve.nix
    ./modules/hydra.nix
    ./modules/zookeeper.nix
    ./modules/apache-kakfa.nix
    ./modules/kibana.nix
    ./modules/logstash.nix
    ./modules/netdata.nix
    ./modules/zeek.nix
    ./elk
  ];

  home.packages = with ownpkgs; [
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
    (zeek.override{ KafkaPlugin = true; PostgresqlPlugin = true; SpicyPlugin = true; })
   ];

  services.zeek = {
    enable = true;
    standalone = true;
    interface = "enp0s3";
    listenAddress = "localhost";
    package = zeek.override{ KafkaPlugin = true; PostgresqlPlugin = true; SpicyPlugin = true; };
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
    listenHost = "127.0.0.1";
    port = 9001;
    package = nixpkgs.hydra-unstable.overrideAttrs(oldAttrs:{
      version = "2020-05-12";
      src = nixpkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "hydra";
      rev = "d5844897da55eb874d561a2a5f10a04b151c64a8";
      sha256 = "0f11w561k6aj6x3dcn4iharxjm9fkkwlfq7xkncfrx4sq7cvwj9f";
      };
    });
    max_job = 24;
    hydraURL = "http://127.0.0.1";
    notificationSender = "gtrun@hardenedlinux.org";
    useSubstitutes = true;
    logo = "${home_directory}/.config/nixpkgs/img/logo_no_background_color_white.png";
  };



  services.vast = {
    enable = true;
    endpoint = "localhost:4000";
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
  secretKeyFile = "${home_directory}/.config/key/cache-priv-key.pem";
  };
}
