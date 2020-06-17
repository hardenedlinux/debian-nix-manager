{ config, lib, pkgs, ... }:
let
  spl-spt = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).spl-spt;
  IRC-Zeek-package = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).IRC-Zeek-package;
  IRC-Behavioral-Analysis = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).IRC-Behavioral-Analysis;
  zeek-EternalSafety = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).zeek-EternalSafety;
  hardenedlinux-zeek-script  = (pkgs.callPackage ./hardenedlinux-zeek-script.nix){inherit pkgs;};
in
{
  home.file = {
    ".zeek-script/__load__.zeek".text = ''
    @load ${spl-spt}/scripts
    ##@load ${IRC-Zeek-package}
    @unload protocols/conn/known-hosts
    @load ${zeek-EternalSafety}/scripts
    @load ${hardenedlinux-zeek-script}/zeek-kafka.zeek
    '';
  };
}
