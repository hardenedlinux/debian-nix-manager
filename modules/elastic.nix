{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.elasticsearch;

  es6 = builtins.compareVersions cfg.package.version "6" >= 0;

  esConfig = ''
    network.host: ${cfg.listenAddress}
    cluster.name: "thehive"

    http.port: "9400"
    transport.tcp.port: "9500"

    ${cfg.extraConf}
  '';

  es7Config = ''
    network.host: ${cfg.listenAddress}
    cluster.name: ${cfg.cluster_name}

    http.port: ${toString cfg.port}
    transport.tcp.port: ${toString cfg.tcp_port}

    ${cfg.extraConf}
  '';

  configDir = cfg.dataDir + "/config";
  configDir7 = cfg.dataDir + "/7/config";

  ES_JAVA_OPTS = toString ([ "-Des.path.conf=${configDir}" ]
    ++ cfg.extraJavaOptions);

  elasticsearchYml = pkgs.writeTextFile {
    name = "elasticsearch.yml";
    text = esConfig;
  };

  elasticsearch7Yml = pkgs.writeTextFile {
    name = "elasticsearch.yml";
    text = es7Config;
  };

  loggingConfigFilename = "log4j2.properties";

  loggingConfigFile = pkgs.writeTextFile {
    name = loggingConfigFilename;
    text = cfg.logging;
  };

  esPlugins = pkgs.buildEnv {
    name = "elasticsearch-plugins";
    paths = cfg.plugins;
    postBuild = "${pkgs.coreutils}/bin/mkdir -p $out/plugins";
  };

in
{

  ###### interface

  options.services.elasticsearch = {
    enable = mkOption {
      description = "Whether to enable elasticsearch.";
      default = false;
      type = types.bool;
    };

    package = mkOption {
      description = "Elasticsearch package to use.";
      default = pkgs.elasticsearch;
      defaultText = "pkgs.elasticsearch";
      type = types.package;
    };

    package-7x = mkOption {
      description = "Elasticsearch package to use.";
      default = cfg.package-7x;
      defaultText = "pkgs.elasticsearch";
      type = types.package;
    };

    listenAddress = mkOption {
      description = "Elasticsearch listen address.";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Elasticsearch port to listen for HTTP traffic.";
      default = 9200;
      type = types.int;
    };

    tcp_port = mkOption {
      description = "Elasticsearch port for the node to node communication.";
      default = 9300;
      type = types.int;
    };

    cluster_name = mkOption {
      description = "Elasticsearch name that identifies your cluster for auto-discovery.";
      default = "elasticsearch";
      type = types.str;
    };

    extraConf = mkOption {
      description = "Extra configuration for elasticsearch.";
      default = "";
      type = types.str;
      example = ''
        node.name: "elasticsearch"
        node.master: true
        node.data: false
      '';
    };

    logging = mkOption {
      description = "Elasticsearch logging configuration.";
      default = ''
        logger.action.name = org.elasticsearch.action
        logger.action.level = info

        appender.console.type = Console
        appender.console.name = console
        appender.console.layout.type = PatternLayout
        appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

        rootLogger.level = info
        rootLogger.appenderRef.console.ref = console
      '';
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/elasticsearch";
      description = ''
        Data directory for elasticsearch.
      '';
    };

    extraCmdLineOptions = mkOption {
      description = "Extra command line options for the elasticsearch launcher.";
      default = [ ];
      type = types.listOf types.str;
    };

    extraJavaOptions = mkOption {
      description = "Extra command line options for Java.";
      default = [ ];
      type = types.listOf types.str;
      example = [ "-Djava.net.preferIPv4Stack=true" ];
    };

    plugins = mkOption {
      description = "Extra elasticsearch plugins";
      default = [ ];
      type = types.listOf types.package;
      example = lib.literalExample "[ pkgs.elasticsearchPlugins.discovery-ec2 ]";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.user.services.elasticsearch = {
      Unit = {
        description = "Elasticsearch Daemon";
        after = [ "network.target" ];
      };
      Install = { WantedBy = [ "multi-user.target" ]; };
      Service = {
        ExecStart = "${cfg.package}/bin/elasticsearch ${toString cfg.extraCmdLineOptions}";
        #PermissionsStartOnly = true;
        Environment = "ES_HOME=${cfg.dataDir}";
        EX = "sd";
        LimitNOFILE = "1024000";
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c 'rm -rf /var/lib/elasticsearch/config; ln -sfT ${esPlugins}/plugins ${cfg.dataDir}/plugins; ln -sfT ${cfg.package}/lib ${cfg.dataDir}/lib; ln -sfT ${cfg.package}/modules ${cfg.dataDir}/modules; mkdir -p /var/lib/elasticsearch/config; cp ${elasticsearchYml} ${configDir}/elasticsearch.yml; rm -f ${configDir}/logging.yml; cp ${loggingConfigFile} ${configDir}/${loggingConfigFilename}; ${optionalString es6 "cp ${cfg.package}/config/jvm.options ${configDir}/jvm.options"}'
        '';
      };
    };

    systemd.user.services.elasticsearch-7x = {
      Unit = {
        description = "Elasticsearch Daemon";
        after = [ "network.target" ];
      };
      Install = { WantedBy = [ "multi-user.target" ]; };
      Service = {
        ExecStart = "${cfg.package-7x}/bin/elasticsearch ${toString cfg.extraCmdLineOptions}";
        #PermissionsStartOnly = true;
        Environment = "ES_HOME=${cfg.dataDir}/7";
        ES_JAVA_OPTS = "${ES_JAVA_OPTS}";
        LimitNOFILE = "1024000";
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c 'rm -rf /var/lib/elasticsearch/7/config; ln -sfT ${esPlugins}/plugins ${cfg.dataDir}/7/plugins; ln -sfT ${cfg.package-7x}/lib ${cfg.dataDir}/7/lib; ln -sfT ${cfg.package-7x}/modules ${cfg.dataDir}/7/modules; mkdir -p /var/lib/elasticsearch/7/config; cp ${elasticsearch7Yml} ${configDir7}/elasticsearch.yml; rm -f ${configDir7}/logging.yml; cp ${loggingConfigFile} ${configDir7}/${loggingConfigFilename}; cp ${cfg.package-7x}/config/jvm.options ${configDir7}/jvm.options'
        '';
      };
    };

    home.packages = [ cfg.package ];
  };
}
