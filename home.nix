{ config, lib, ... }:
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
    ./profiles
    ./modules
    ./lib
    ./elk
    ./pkgs/network
    ./pkgs/zeek
    ./pkgs/hardenedlinux.nix
    ./modules/pre-modules.nix
  ];

  home.stateVersion = "20.03";
}
