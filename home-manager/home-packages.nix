{ config, pkgs, ... }:
let
     clean-nix-store = pkgs.writeScriptBin "clean-nix-store" (import ../bin/clean-nix-store.nix { });
     deploy-home-manager = pkgs.writeScriptBin "deploy-home-manager" (import ../bin/deploy-home-manager.nix { });
in
{
   home.packages = with pkgs;[ curl
                                 clean-nix-store
                                 deploy-home-manager
                                 system-sendmail
                                 tree
                                 zip
                                 unzip
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
                                 #certbot
                                 aria2
                                 gotty
                                 nettools
                                 exa
                                 pwgen
                               ];
}
