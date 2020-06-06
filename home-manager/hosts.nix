{ config, lib, pkgs, ... }:
let
  machine = (builtins.fromJSON (builtins.readFile ./hosts-resource.json)).debian;
in
{
  options.hosts.compiler = with lib; {
     username = mkOption {
      type = types.str;
      default = machine.username;
      description = "hosts username";
     };

     interface_1.ip = mkOption {
      type = types.str;
      default = machine.interface_1.ip;
      description = "hosts username";
    };

     interface_1.name = mkOption {
      type = types.str;
      default = machine.interface_1.name;
      description = "hosts username";
    };

  };
}
