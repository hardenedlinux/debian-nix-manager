self: super:
let
  nixpkgs-hardenedlinux = super.fetchgit {
    url = "https://github.com/hardenedlinux/nixpkgs-hardenedlinux";
    rev = "bd99eb5e9a3f1c6d43d49f4873457ecc5ecf9440";
    sha256 = "15snlj4j87c1y3kaaskdc0hvlxlyrfdjq8dlpsfjw3cbb999vn03";
  };
in
{
  zeek = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/zeek" {KafkaPlugin = true; PostgresqlPlugin = true; Http2Plugin = true;};
  vast = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/vast" { };
  pf-ring = super.callPackage ../pkgs/network/pf_ring.nix { };
  osquery = super.callPackages ../pkgs/osquery { };
  #emacs = super.callPackage ../pkgs/nix-emacs-ci/emacs.nix { version = "28.0.50"; sha256 = "0idd8k1lsk4qsh6jywm72rrdpcbdirsg5d1wdvsqfv1b336gyb3r"; withAutoReconf = true; };
}
