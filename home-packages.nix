{ config, pkgs, ... }:
let
  zeek = pkgs.callPackages ./pkgs/zeek { };

  in
{
  home.packages = with pkgs;[
    fish-foreign-env
	  curl
	  git
    bash
    pet
	  kitty
	  tmux
	  autojump
	  cmake
	  gcc
	  stdenv
    fd
	  gnumake
    direnv
    (python3.withPackages (pkgs: with pkgs; [
      # rl algorithms
      dbus
      qrcode
      pyqt5
      fontforge
	  ]))
    #emacsPackages
  ];
}
