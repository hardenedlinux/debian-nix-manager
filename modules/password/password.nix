{ config, lib, pkgs, ... }:

{
  options.password = with lib; {
    ##pwgen -yB 24
    nsm-postgresql = mkOption {
      type = types.str;
      default = (builtins.fromJSON (builtins.readFile ./password.json)).nsm.psql.hydra;
      description = "Public config path";
    };
  };
}
