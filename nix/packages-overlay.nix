final: prev:
let
  nixpkgs-hardenedlinux-locked = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs-hardenedlinux.locked;
  zeek-nix-locked = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.zeek-nix.locked;

  nixpkgs-hardenedlinux = builtins.fetchTarball {
    url = "https://github.com/${nixpkgs-hardenedlinux-locked.owner}/${nixpkgs-hardenedlinux-locked.repo}/archive/${nixpkgs-hardenedlinux-locked.rev}.tar.gz";
    sha256 = nixpkgs-hardenedlinux-locked.narHash;
  };

  zeek-nix = builtins.fetchTarball {
    url = "https://github.com/${zeek-nix-locked.owner}/${zeek-nix-locked.repo}/archive/${zeek-nix-locked.rev}.tar.gz";
    sha256 = zeek-nix-locked.narHash;
  };


in
{
  zeek = prev.callPackage "${zeek-nix}" {KafkaPlugin = true; PostgresqlPlugin = true; Http2Plugin = true;};
  vast = prev.callPackage "${nixpkgs-hardenedlinux}/pkgs/vast" { };
  pf-ring = prev.callPackage ../pkgs/network/pf_ring.nix { };
  osquery = prev.callPackages ../pkgs/osquery { };
}
