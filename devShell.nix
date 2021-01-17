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
    echo "${nixpkgs-locked.rev}"
    if grep -q "${nixpkgs-locked.rev}" <<< $currentNixpkgs; then
       echo "No nixpkgs update"
        else
             nix-channel --add https://github.com/NixOS/nixpkgs/archive/${nixpkgs-locked.rev}.tar.gz nixpkgs
             nix-channel --add https://github.com/${home-locked.owner}/${home-locked.repo}/archive/${home-locked.rev}.tar.gz home-manager
             nix-channel --update
     fi
    home-manager build -f home.nix -I nixpkgs=${pkgsChannel}
    '';
}
