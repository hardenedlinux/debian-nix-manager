{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.hydra;

  baseDir = "/var/lib/hydra";

  hydraConf = pkgs.writeScript "hydra.conf" cfg.extraConfig;

  hydraEnv =
    { HYDRA_DBI = cfg.dbi;
      HYDRA_CONFIG = "${baseDir}/hydra.conf";
      HYDRA_DATA = "${baseDir}";
    };

  env =
    { NIX_REMOTE = "daemon";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"; # Remove in 16.03
      PGPASSFILE = "${baseDir}/pgpass";
      #NIX_REMOTE_SYSTEMS = concatStringsSep ":" cfg.buildMachinesFiles;
    } // optionalAttrs (cfg.smtpHost != null) {
      EMAIL_SENDER_TRANSPORT = "SMTP";
      EMAIL_SENDER_TRANSPORT_host = cfg.smtpHost;
    } // hydraEnv // cfg.extraEnv;

  serverEnv = env //
    { HYDRA_TRACKER = cfg.tracker;
      XDG_CACHE_HOME = "${baseDir}/www/.cache";
      COLUMNS = "80";
      #PGPASSFILE = "${baseDir}/pgpass-www"; # grrr
    } // (optionalAttrs cfg.debugServer { DBIC_TRACE = "1"; });

  localDB = "dbi:Pg:dbname=hydra;host=localhost;user=hydra";

  haveLocalDB = cfg.dbi == localDB;

in

{
  ###### interface
  options = {

    services.hydra = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run Hydra services.
        '';
      };

      dbi = mkOption {
        type = types.str;
        default = localDB;
        example = "dbi:Pg:dbname=hydra;host=postgres.example.org;user=foo;";
        description = ''
          The DBI string for Hydra database connection.
        '';
      };

      package = mkOption {
        type = types.package;
        defaultText = "pkgs.hydra";
        description = "The Hydra package.";
      };

      hydraURL = mkOption {
        type = types.str;
        description = ''
          The base URL for the Hydra webserver instance. Used for links in emails.
        '';
      };

      listenHost = mkOption {
        type = types.str;
        default = "*";
        example = "localhost";
        description = ''
          The hostname or address to listen on or <literal>*</literal> to listen
          on all interfaces.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 3000;
        description = ''
          TCP port the web server should listen to.
        '';
      };

      minimumDiskFree = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Threshold of minimum disk space (GiB) to determine if the queue runner should run or not.
        '';
      };

      minimumDiskFreeEvaluator = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Threshold of minimum disk space (GiB) to determine if the evaluator should run or not.
        '';
      };

      max_job = mkOption {
      description = "set max_job number";
      default = 8;
      type = types.int;
    };
      notificationSender = mkOption {
        type = types.str;
        description = ''
          Sender email address used for email notifications.
        '';
      };

      smtpHost = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = ["localhost"];
        description = ''
          Hostname of the SMTP server to use to send email.
        '';
      };

      tracker = mkOption {
        type = types.str;
        default = "";
        description = ''
          Piece of HTML that is included on all pages.
        '';
      };

      logo = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a file containing the logo of your Hydra instance.
        '';
      };

      debugServer = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to run the server in debug mode.";
      };

      extraConfig = mkOption {
        type = types.lines;
        description = "Extra lines for the Hydra configuration.";
      };

      extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Extra Environment variables for Hydra.";
      };

      gcRootsDir = mkOption {
        type = types.path;
        default = "/nix/var/nix/gcroots/hydra";
        description = "Directory that holds Hydra garbage collector roots.";
      };

      # buildMachinesFiles = mkOption {
      #   type = types.listOf types.path;
      #   default = optional (config.nix.buildMachines != []) "/etc/nix/machines";
      #   example = [ "/etc/nix/machines" "/var/lib/hydra/provisioner/machines" ];
      #   description = "List of files containing build machines.";
      # };

      useSubstitutes = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use binary caches for downloading store paths. Note that
          binary substitutions trigger (a potentially large number of) additional
          HTTP requests that slow down the queue monitor thread significantly.
          Also, this Hydra instance will serve those downloaded store paths to
          its users with its own signature attached as if it had built them
          itself, so don't enable this feature unless your active binary caches
          are absolute trustworthy.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.hydra.extraConfig =
      ''
        using_frontend_proxy = 1
        base_uri = ${cfg.hydraURL}
        notification_sender = ${cfg.notificationSender}
        max_servers = 25
        ${optionalString (cfg.logo != null) ''
          hydra_logo = ${cfg.logo}
        ''}
        gc_roots_dir = ${cfg.gcRootsDir}
        use-substitutes = ${if cfg.useSubstitutes then "1" else "0"}
      '';

    home.packages = [ cfg.package ];

#    Environment.variables = hydraEnv;

    systemd.user.services.hydra-server =
      {
        Install = { wantedBy = [ "multi-user.target" ];};
        Unit = {
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" ];
        };
        #restartTriggers = [ hydraConf ];
        environment = serverEnv;
        Service =
          { ExecStart =
              "${cfg.package}/bin/hydra-server hydra-server -f -h '${cfg.listenHost}' "
              + "-p ${toString cfg.port} --max_spare_servers 5 --max_servers 25 "
              + "--max_requests 100 ${optionalString cfg.debugServer "-d"}";
            #PermissionsStartOnly = true;
            ExecStartPre = ''${pkgs.bash}/bin/bash -c '${cfg.package}/bin/hydra-init; ln -sf ${hydraConf} ${baseDir}/hydra.conf'
            '';
            Restart = "always";
            Environment = [
              ''"PAHT=${cfg.package}/bin"''
              ''"PGPASSFILE=/var/lib/hydra/pgpass"''
              ''"HYDRA_DBI=dbi:Pg:dbname=hydra;host=localhost;user=hydra;password=${import /var/lib/hydra/pgpass}"''
              ''"HYDRA_CONFIG=${baseDir}/hydra.conf"''
            ];
          };
      };

    systemd.user.services.hydra-queue-runner =
      {
        Install = { wantedBy = [ "multi-user.target" ];};
        Unit = {
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" "network.target" ];
        };
        #path = [ cfg.package pkgs.nettools pkgs.openssh pkgs.bzip2 config.nix.package ];
        #restartTriggers = [ hydraConf ];
        Service =
          { ExecStart = "${cfg.package}/bin/hydra-queue-runner -j ${toString cfg.max_job} -v --option build-use-substitutes true";
            ExecStopPost = "${cfg.package}/bin/hydra-queue-runner --unlock";
            Restart = "always";

            Environment = [
              ''"HYDRA_DATA=/var/lib/hydra"''
              ''"NIX_BUILD_CORES=12"''
              ''"IN_SYSTEMD=1"''            # to get log severity levels
              ''"HYDRA_CONFIG=${baseDir}/hydra.conf"''
            ];
            # Ensure we can get core dumps.
            LimitCORE = "infinity";
            WorkingDirectory = "${baseDir}/queue-runner";
          };
      };

    systemd.user.services.hydra-evaluator =
      {
        Unit = {
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" "network.target" ];
        };

        Install = { wantedBy = [ "multi-user.target" ];};
        #path = with pkgs; [ cfg.package nettools jq ];
        #restartTriggers = [ hydraConf ];
        Service =
          { ExecStart = "@${cfg.package}/bin/hydra-evaluator hydra-evaluator";
            Restart = "always";
            Environment = [
              ''"HYDRA_DBI=dbi:Pg:dbname=hydra;host=localhost;user=hydra;password=${import /var/lib/hydra/pgpass}"''
              ''"PATH=${makeBinPath [ pkgs.nettools pkgs.jq cfg.package ]}"''
            ];

            WorkingDirectory = baseDir;
          };
      };

    systemd.user.services.hydra-update-gc-roots =
      {
        Install = { wantedBy = [ "multi-user.target" ];};
        Unit = {
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" "network.target" ];
        };
        Service =
          { ExecStart = "@${cfg.package}/bin/hydra-update-gc-roots hydra-update-gc-roots";
            #Environment = env;
          };
        #startAt = "2,14:15";
      };

    systemd.user.services.hydra-send-stats =
      {
        Install = { wantedBy = [ "multi-user.target" ];};
        Unit = {
          after = [ "hydra-init.service" "network.target" ];
        };
        Service =
          { ExecStart = "@${cfg.package}/bin/hydra-send-stats hydra-send-stats";
            User = "hydra";
            #Environment = env;
          };
      };
    systemd.user.services.hydra-notify =
      {
        Install = { wantedBy = [ "multi-user.target" ];};
        Unit = {
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" ];
        };
        #restartTriggers = [ hydraConf ];
        Service =
          {
            # Environment = env // {
            #   PGPASSFILE = "${baseDir}/pgpass-queue-runner";
            # };
            ExecStart = "@${cfg.package}/bin/hydra-notify hydra-notify";
            # FIXME: run this under a less privileged user?
            Restart = "always";
            RestartSec = 5;
          };
      };
  };
}
