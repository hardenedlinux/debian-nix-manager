{ pkgs
, pkgsChannel
}:
let
  nixpkgs-locked = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
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
             nix-channel --update
     fi
    home-manager build -f home.nix -I nixpkgs=${pkgsChannel}
    '';
}
