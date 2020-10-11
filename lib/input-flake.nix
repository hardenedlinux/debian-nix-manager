{ lib, ... }:
with lib;
let
  nixpkgs-hardenedlinux-locked = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs-hardenedlinux.locked;
  zeek-nix-locked = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.zeek-nix.locked;
in
{
  flakeLock = importJSON ../flake.lock;
  importJSON = file: builtins.fromJSON (builtins.readFile file);
  loadInput = { locked, ... }:
    assert locked.type == "github";
    builtins.fetchTarball {
      url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
      sha256 = locked.narHash;
    };

  nixpkgs-hardenedlinux = builtins.fetchTarball {
    url = "https://github.com/${nixpkgs-hardenedlinux-locked.owner}/${nixpkgs-hardenedlinux-locked.repo}/archive/${nixpkgs-hardenedlinux-locked.rev}.tar.gz";
    sha256 = nixpkgs-hardenedlinux-locked.narHash;
  };
}
