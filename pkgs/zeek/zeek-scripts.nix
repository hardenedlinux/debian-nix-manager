{ config
, pkgs
, lib
,  ... }:
let
  inherit (inputflake) loadInput flakeLock;
  inputflake = import ../../lib/input-flake.nix {inherit lib;};
  IRC-Zeek-package = loadInput flakeLock.nodes.IRC-Zeek-package;
  IRC-Behavioral-Analysis = loadInput flakeLock.nodes.IRC-Behavioral-Analysis;
  zeek-EternalSafety = loadInput flakeLock.nodes.zeek-EternalSafety;
  spl-spt = loadInput flakeLock.nodes.spl-spt;
  #spl-spt = pkgs.IRC-Zeek-packagefetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).spl-spt;
  hardenedlinux-zeek-script  = (pkgs.callPackage ./hardenedlinux-zeek-script.nix){inherit pkgs;};
in
{
  home.file = {
    ".zeek-script/__load__.zeek".text = ''
    @load ${spl-spt}/scripts #spl-spt
    ##@load ${IRC-Zeek-package} #IRC-Zeek-package
    @unload protocols/conn/known-hosts
    @load ${zeek-EternalSafety}/scripts
    @load ${hardenedlinux-zeek-script}/zeek-kafka.zeek
    '';
  };
}
