{ config, pkgs, ... }:
let
   clean-nix-store = pkgs.writeScriptBin "clean-nix-store" (import ../bin/clean-nix-store.nix { });
in
{
  home.packages = with pkgs;[ clean-nix-store
                              systemd
                              system-sendmail

                              #for nix
                              nixUnstable

                              
                              git-crypt
                              git
                              pinentry

                              curl
                              tree
                              zip
                              unzip
                              autojump
                              fd
                              kmod
                              ripgrep
                              ag
                              fzf

                              tcpreplay
                              nettools
                              exa
                              pwgen


                              cmake
                              gcc9
                              gnumake


                              nodejs
                            ];
}
