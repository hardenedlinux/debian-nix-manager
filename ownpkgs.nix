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
  # vast = (import (ownpkgs.fetchgit {
  #   url = "https://github.com/tenzir/vast";
  #   rev = "295d0ff776026b4600df7360409f6830ebe0b0fe";
  #   deepClone = true;
  #   sha256 = "1nmh7wqqq6i72yam5g8a2nclcf3jchzd7s5vx5bx2jgsbllzclch";
  # }){});

in
{
  imports = [
    ./module/vast.nix
  ];

  home.packages = with ownpkgs; [
    zeek
    vast
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
    ]))
    (emacsPackages.emacsWithPackages (with pkgs.emacsPackagesNg; [
    emacs-libvterm
    ]))
    ];


  services.vast = {
    enable = true;
    endpoint = "localhost:4000";
    #db-directory = "./vast/vast.db";
    #log-directory = "./vast/vast.log";
  };



}
