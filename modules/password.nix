{ config, lib, pkgs, ... }:

{
  options.password = with lib; {
    postgresql = mkOption {
      type = types.str;
      default = (builtins.fromJSON (builtins.readFile ./password.json)).nsm.psql.hydra;
      description = "Public config path";
    };
  };
}
