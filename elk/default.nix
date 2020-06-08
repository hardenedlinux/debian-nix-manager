{ config, lib, pkgs, ... }:
{
  imports = [
    ./elk-user_host_2.nix #my testhost
    ./elk-user_host_1.nix #compiler host
    ../modules/password/password.nix
  ];

  home.file.".debian-nsm-password".text = ''
  ${config.host_1.username}
'';
}
