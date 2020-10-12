{config, pkgs, lib, ...}:
{
  config = with lib; mkMerge [
    (mkIf (config.home.username == config.host_2.username ) {
      services.zeek = {
        enable = true;
        standalone = true;
        package = pkgs.zeek;
        interface = config.host_2.interface_2.name;
        listenAddress = config.host_2.interface_2.ip;
        #Tue Jun 16 11:57:31 HKT 2020'
        privateScript = ''
        @load ${config.home.homeDirectory}/.zeek-script
        '';
      };

      services.netdata = {
        enable = true;
      };

      services.zookeeper = {
        enable = true;
      };


      services.apache-kafka = {
        enable = true;
        #brokerId=1;
        logDirs = ["/var/lib/kafka/log"];
      };

      services.vast = {
        enable = true;
        endpoint = "localhost:4000";
        package = pkgs.vast;
        #db-directory = "./vast/vast.db";
        #log-directory = "./vast/vast.log";
      };

      services.osquery = {
        enable = true;
      };


      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_11 ;
        dataDir = "/var/db/postgresql/11";
      };
    })
  ];
}
