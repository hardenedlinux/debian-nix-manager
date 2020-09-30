let
  rev = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked.rev;
  src = builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    sha256 = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked.narHash;
  };
in
import src
