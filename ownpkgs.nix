{pkgs, ...}:
let
  nixpkgs = (import ~/.config/nixpkgs/channel/nixpkgs) { };
  unstable = import <nixpkgs-unstable> { };

  ownpkgs_git = builtins.fetchTarball {
    url = "https://github.com/GTrunSec/nixpkgs/tarball/806fac5d109cdc6653c33a18924dac31ac477a2b";
    sha256 = "0b1aksy1070xh9wn7mwdgyz2hpfljr4jxs6qj90x7pnxj3m3p7a4";
  };
  elastic_5x = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/8673d82bc18d3c6af28b1e3fe5c109276b5121ed";
    sha256 = "1d9hv2cc247vm3rrky6k3706k958128213r0j0hyakpafqy4qz55";
  };
  elastic5 = (import elastic_5x) { };
  ownpkgs = (import ownpkgs_git) { };
  zeek = ownpkgs.callPackages ./pkgs/zeek { };
  vast = ownpkgs.callPackages ./pkgs/vast { };
  pf-ring = ownpkgs.callPackages ./pkgs/network/pf_ring.nix { };

in
{
  imports = [
    ./modules/vast.nix
    ./modules/osquery
    ./modules/elastic.nix
    ./modules/postgresql.nix
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
    cluster_name = "thehive";
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11 ;
    dataDir = "/var/db/postgresql/11";
    };

}
