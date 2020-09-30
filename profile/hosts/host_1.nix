{ config, lib, pkgs, ... }:
let
  #for compiler
  machine = (builtins.fromJSON (builtins.readFile ./hosts-resource.json)).host_1;
in
{
  options.host_1 = with lib; {
     username = mkOption {
      type = types.str;
      default = machine.username;
      description = "hosts username";
     };

     interface_1.ip = mkOption {
      type = types.str;
      default = machine.interface_1.ip;
      description = "hosts interface for Zeek";
    };

     interface_1.name = mkOption {
      type = types.str;
      default = machine.interface_1.name;
      description = "hosts username";
    };

  };
}
