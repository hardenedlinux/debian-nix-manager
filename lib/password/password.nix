{ lib, ... }:

{
  options.password = with lib; {
    ##pwgen -yB 24
    nsm-postgresql = mkOption {
      type = types.str;
      default = (builtins.fromJSON (builtins.readFile ../../secrets/password.json)).debian.psql.hydra;
      description = "For username of debian config password path";
    };
  };
}
