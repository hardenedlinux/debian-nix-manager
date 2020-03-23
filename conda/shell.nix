{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  my-python = python3Packages.python.withPackages( ps: with ps; [
    geopandas
    shapely
  ]);
in

mkShell {
  buildInputs = [
    conda
    git
    my-python
    musl
  ];

  shellHooks = ''
  export PATH="${pkgs.stdenv.lib.makeBinPath ([ my-python ])}''${PATH:+:}$PATH"
  conda-shell
  '';
}
