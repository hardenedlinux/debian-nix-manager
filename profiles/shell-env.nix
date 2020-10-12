{ config, lib, pkgs, ... }:
let
  inherit (inputflake) nixpkgs-hardenedlinux;
  inputflake = import ../lib/input-flake.nix {inherit lib;};
  timesketch = pkgs.writeScriptBin "timesketch" ''
  nix-shell ${nixpkgs-hardenedlinux}/pkgs/python/env/timesketch/shell.nix --command "tsctl $1"
'';
in

{
  home.packages = with pkgs;[
    timesketch
  ];
  
}
