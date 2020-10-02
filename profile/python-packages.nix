{ config, pkgs, ... }:

{
  home.packages = with pkgs;[
    (python37.withPackages (nixpkgs: with nixpkgs; [
      shapely
      matplotlib
    ]))
  ];
}
