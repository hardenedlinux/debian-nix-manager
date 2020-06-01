{ config, lib, pkgs, ... }:
{
  imports = [
    ./elk-user_test.nix
    ./elk-user_nsm.nix
    ../modules/password/password.nix
  ];

  home.file.".debian-nsm-password".text = ''
  ${config.hosts.compiler.username}
'';
}
