{ config, lib, pkgs, ... }:

{
  imports = [
    ./host_1.nix
    ./host_1-modules.nix
    ./host_2.nix
  ];
}
