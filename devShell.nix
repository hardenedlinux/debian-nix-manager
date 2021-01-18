{ pkgs
, pkgsChannel
, homeChannel
}:
let
  nixpkgs-locked = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
  home-locked = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.home.locked;
in
pkgs.mkShell {
  buildInputs = with pkgs;[
    home-manager
  ];
  shellHook = ''
  export NIX_PATH="$HOME/.nix-defexpr/channels"
  export NIX_PATH=$HOME/.nix-defexpr/channels'$'\{NIX_PATH:+:}$NIX_PATH
  export TERM=xterm

  nix-channel --add https://github.com/NixOS/nixpkgs/archive/${nixpkgs-locked.rev}.tar.gz nixpkgs
  nix-channel --add https://github.com/${home-locked.owner}/${home-locked.repo}/archive/${home-locked.rev}.tar.gz home-manager
  nix-channel --update
  home-manager build -f home.nix -I nixpkgs=${pkgsChannel}
  #home-manager build -f home.nix -I nixpkgs=${pkgsChannel} --option substituters http://221.4.35.244:8301
    '';
}
