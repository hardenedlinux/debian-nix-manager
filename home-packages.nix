{ config, pkgs, ... }:
let
     osquery = pkgs.callPackages ./pkgs/osquery { };
in
{
  home.packages = with pkgs;[ curl
	                            git
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
                              kmod
                              postgresql
                              ripgrep
                              ag
                              fzf
                              jre_headless
                              certbot
                              aria2
                              gotty
                              nettools
                              exa
                              pwgen
                            ];
}
