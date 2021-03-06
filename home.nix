{ config, lib, ... }:
let
  log_directory = "${config.home.homeDirectory}/logs";
  emacs-overlay-rev = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.emacs-overlay.locked.rev;
in
{
  nixpkgs.overlays = [
    (import ./nix/packages-overlay.nix)
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${emacs-overlay-rev}.tar.gz";
    }))
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
    ./pkgs/network
    ./pkgs/zeek
    ./pkgs/hardenedlinux.nix
    ./modules/pre-modules.nix
  ];

  home.stateVersion = "20.03";
}
