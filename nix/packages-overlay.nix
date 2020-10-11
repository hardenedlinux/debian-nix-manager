self: super:
let
  nixpkgs-hardenedlinux-locked = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs-hardenedlinux.locked;
  nixpkgs-hardenedlinux = super.fetchgit {
    url = "${nixpkgs-hardenedlinux-locked.url}";
    rev = "${nixpkgs-hardenedlinux-locked.rev}";
    sha256 = "sha256-hi1nL7I3qS5BxmA8f+kC0rQQ4YgPJwtKG4r5FP/ttNY=";
  };
in
{
  zeek = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/zeek" {KafkaPlugin = true; PostgresqlPlugin = true; Http2Plugin = true;};
  vast = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/vast" { };
  pf-ring = super.callPackage ../pkgs/network/pf_ring.nix { };
  osquery = super.callPackages ../pkgs/osquery { };
}
