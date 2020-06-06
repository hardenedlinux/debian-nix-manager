self: super:
let
  nixpkgs-hardenedlinux = super.fetchgit {
    url = "https://github.com/hardenedlinux/nixpkgs-hardenedlinux";
    rev = "c0db92ae4c4f52cc7f27fc120c2fa8d1d7effb28";
    sha256 = "0yrjdq6gd27z8bdpah4rajfhnc7mxnw4i4k730zm2qkd76mkknss";
  };
in
{
  zeek = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/zeek" { };
  vast = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/vast" { };
  pf-ring = super.callPackage ../pkgs/network/pf_ring.nix { };
  osquery = super.callPackages ../pkgs/osquery { };
}
