{ config, pkgs, lib, ... }:
with lib;
{
  systemd.user.services.dropbox = {
    Unit = {
      description = "Dropbox";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };

    environment = {
      QT_PLUGIN_PATH = "$HOME/.nix-profile/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "$HOME/.nix-profile/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    Service = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "always";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };
}
