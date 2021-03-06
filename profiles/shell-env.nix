{ config, lib, pkgs, ... }:
let
  fetch = import ../lib/input-flake.nix;
  nixpkgs-hardenedlinux = fetch "nixpkgs-hardenedlinux";
  timesketch = pkgs.writeScriptBin "timesketch" ''
    nix-shell ${nixpkgs-hardenedlinux}/pkgs/python/env/timesketch/shell.nix --command "tsctl $1"
  '';
in
{
  home.packages = with pkgs;[
    timesketch
  ];

}
