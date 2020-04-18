{ config, lib, pkgs, ... }:

{
  imports = [
    ./elk-user_test.nix
    ./elk-user_nsm.nix
    ../modules/password.nix
  ];
  home.file."sdsd".text = ''
  ${config.password.postgresql}
'';
}
