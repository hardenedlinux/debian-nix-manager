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
    cudatoolkit
  ];

  shellHooks = ''
  export PATH="${pkgs.stdenv.lib.makeBinPath ([ my-python ])}''${PATH:+:}$PATH"
  export CUDA_PATH="${pkgs.cudatoolkit}"
  conda-shell && conda activate clx-fast.ai
  '';
}
