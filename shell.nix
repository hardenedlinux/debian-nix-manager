{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    pkgs.zeek
    home-manager
  ];
  shellHook = ''
    home-manager build
    '';
}
