{pkgs} :
let
  hardenedlinux-zeek-script-src = builtins.fetchGit {
    url = https://github.com/hardenedlinux/hardenedlinux-zeek-script;
    rev = "3d83134afda11e49b0bb99a7dac57e13df5127fb";
    ref = "master";
  };

in
  pkgs.stdenv.mkDerivation rec {
    name = "hardenedlinux-zeek-script";
    phases = [ "installPhase" ];
    buildInputs = [ hardenedlinux-zeek-script-src ];
    installPhase = ''
    cp -r ${hardenedlinux-zeek-script-src}/scripts/ $out

    substituteInPlace $out/zeek-kafka.zeek \
    --replace "/usr/local/zeek/lib/zeek/plugins/" "${pkgs.zeek}/lib/zeek/plugins/"

    ## top-1m fix
    substituteInPlace $out/protocols/dns/alexa/alexa_validation.zeek \
    --replace "top-1m.txt" "$out/protocols/dns/alexa/top-1m.txt"

    ## dynamic_dns fix
    substituteInPlace $out/protocols/dns/dyndns.zeek \
    --replace "dynamic_dns.txt" "$out/protocols/dns/dynamic_dns.txt"

   '';
  }
