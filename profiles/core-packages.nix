{ config, pkgs, ... }:
let
  clean-nix-store = pkgs.writeScriptBin "clean-nix-store" (import ../bin/clean-nix-store.nix { });
  deploy-home-manager = pkgs.writeScriptBin "deploy-home-manager" (import ../bin/deploy-home-manager.nix { });
in
{
  home.packages = with pkgs;[
    clean-nix-store
    deploy-home-manager
    systemd
    system-sendmail
    #custom binScript
  ] ++ [
    exa
    pwgen
    cmake
    gcc9
    gnumake
  ] ++ [
    #for nix
    nixpkgs-fmt
    nixUnstable
  ] ++ [

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
  ] ++ [
    nettools
    nodejs
    go
  ] ++ [
  ];
}
