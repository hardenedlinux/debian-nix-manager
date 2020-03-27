{ config, pkgs, ... }:
let
  osquery = pkgs.callPackages ./pkgs/osquery { };
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
      vim
      gdb
      procps
      jq
      pet
      ag
      ripgrep
      #fish pet
      fzf
      conda
      osquery
  ];
}
