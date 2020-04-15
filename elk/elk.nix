{ config, lib, pkgs, ... }:
let
  elastic_5x = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/8673d82bc18d3c6af28b1e3fe5c109276b5121ed";
    sha256 = "1d9hv2cc247vm3rrky6k3706k958128213r0j0hyakpafqy4qz55";
  };

  elastic5 = (import elastic_5x) { };

in
{
    services.logstash = {
    enable = true;
    package = pkgs.logstash7;
    plugins = [ pkgs.logstash-contrib ];
    extraSettings = ''
    config.reload.automatic: true
    config.reload.interval: 3s
    '';
    inputConfig = ''
        '';
  };

  services.kibana = {
    enable = true;
    package = pkgs.kibana7;
    # listenAddress = "10.220.170.113";
    elasticsearch.hosts = [ "http://localhost:9200" ];
  };

  services.elasticsearch = {
    enable = true;
    #for thehive
    package = elastic5.elasticsearch5;
    package-7x = pkgs.elasticsearch7;
    #cluster_name =  "thehive";
    extraJavaOptions = [""];
  };

}
