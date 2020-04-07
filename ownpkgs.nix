{pkgs, ...}:
let
  nixpkgs = (import <nixpkgs> { config.allowUnfree = true; config.ignoreCollisions = true;});
  unstable = (import <unstable> { });
  home_directory = builtins.getEnv "HOME";
  ownpkgs_git = builtins.fetchTarball {
    url = "https://github.com/GTrunSec/nixpkgs/tarball/39247f8d04c04b3ee629a1f85aeedd582bf41cac";
     sha256 = "1q7asvk73w7287d2ghgya2hnvn01szh65n8xczk4x2b169c5rfv0";
    };

  elastic_5x = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/8673d82bc18d3c6af28b1e3fe5c109276b5121ed";
    sha256 = "1d9hv2cc247vm3rrky6k3706k958128213r0j0hyakpafqy4qz55";
  };
  
  elastic5 = (import elastic_5x) { };
  ownpkgs = (import ownpkgs_git) { };
  zeek = ownpkgs.callPackage ./pkgs/zeek { };
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
  ];

  home.packages = with ownpkgs; [
    zeek
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
    (emacsPackages.emacsWithPackages (with pkgs.emacsPackagesNg; [
     emacs-libvterm
    ]))
    wakatime
    go
    polipo
    nodejs
  ];

  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    port = 9001;
    package = nixpkgs.hydra-flakes;
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

  services.elasticsearch = {
    enable = true;
    package = elastic5.elasticsearch5;
    cluster_name =  "thehive";
    #extraJavaOptions = ["test"];
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
