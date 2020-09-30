{ config, lib, pkgs, ... }:
let
  #for compiler
  machine = (builtins.fromJSON (builtins.readFile ./hosts-resource.json)).host_2;
in
{
  options.host_2 = with lib; {
     username = mkOption {
      type = types.str;
      default = machine.username;
      description = "hosts username";
     };

     interface_1.ip = mkOption {
      type = types.str;
      default = machine.interface_1.ip;
      description = "hosts interface ";
    };

     interface_1.name = mkOption {
      type = types.str;
      default = machine.interface_1.name;
      description = "hosts username";
     };

     interface_2.ip = mkOption {
      type = types.str;
      default = machine.interface_2.ip;
      description = "hosts interface ";
    };

     interface_2.name = mkOption {
      type = types.str;
      default = machine.interface_2.name;
      description = "hosts username";
    };
  };
}
