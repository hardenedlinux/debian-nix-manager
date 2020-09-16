self: super:
let
  nixpkgs-hardenedlinux = super.fetchgit {
    url = "https://github.com/hardenedlinux/nixpkgs-hardenedlinux";
    rev = "60ab7b44f6c7b9ae73e273c91c2efb452638074b";
    sha256 = "1z9r7qs9q617sxg8cyxy98ijnaxdjgd9gm8hbwjb0ifi1cgvczjr";
  };
in
{
  zeek = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/zeek" {KafkaPlugin = true; PostgresqlPlugin = true; Http2Plugin = true;};
  vast = super.callPackage "${nixpkgs-hardenedlinux}/pkgs/vast" { };
  pf-ring = super.callPackage ../pkgs/network/pf_ring.nix { };
  osquery = super.callPackages ../pkgs/osquery { };
  #emacs = super.callPackage ../pkgs/nix-emacs-ci/emacs.nix { version = "28.0.50"; sha256 = "0idd8k1lsk4qsh6jywm72rrdpcbdirsg5d1wdvsqfv1b336gyb3r"; withAutoReconf = true; };
}
