{pkgs, ...}:
let
  nixpkgs = (import ~/.config/nixpkgs/channel/nixpkgs) { };
  unstable = import <nixpkgs-unstable> { };

  ownpkgs_git = builtins.fetchTarball {
    url = "https://github.com/GTrunSec/nixpkgs/tarball/806fac5d109cdc6653c33a18924dac31ac477a2b";
    sha256 = "0b1aksy1070xh9wn7mwdgyz2hpfljr4jxs6qj90x7pnxj3m3p7a4";
  };

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
  };

}
