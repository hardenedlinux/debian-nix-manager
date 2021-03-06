{ config
, pkgs
, lib
, ...
}:
let
  fetch = import ../../lib/input-flake.nix;
  IRC-Zeek-package = fetch "IRC-Zeek-package";
  IRC-Behavioral-Analysis = fetch "IRC-Behavioral-Analysis";
  zeek-EternalSafety = fetch "zeek-EternalSafety";
  spl-spt = fetch "spl-spt";
  #spl-spt = pkgs.IRC-Zeek-packagefetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).spl-spt;
  hardenedlinux-zeek-script = (pkgs.callPackage ./hardenedlinux-zeek-script.nix) { inherit pkgs; };
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
