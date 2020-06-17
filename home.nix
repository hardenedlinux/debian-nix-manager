{ config, pkgs, lib, ... }:
let
  log_directory = "${config.home.homeDirectory}/logs";
  #sysconfig = (import <nixpkgs/nixos> {}).config;
in
{
  nixpkgs.overlays = [
    (import ./nix/packages-overlay.nix)
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
    path = "${config.home.homeDirectory}/.nix-defexpr/channels/home-mananger";
  };
  imports = [
    ./home-manager/home-packages.nix
    ./modules
    ./elk
    ./home-manager/home-file.nix
    #./home-manager/fish.nix
    ./home-manager/emacs.nix
    ./home-manager/tmux.nix
    ./home-manager/git.nix
    ./home-manager/zsh.nix
    ./home-manager/ssh.nix
    ./home-manager/hosts
    ./pkgs/network
    ./pkgs/zeek
    ./pkgs/hardenedlinux.nix
  ]; #++ lib.optionals sysconfig.services.xserver.enable [
    #./home-manager/desktop.nix ];
  
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
