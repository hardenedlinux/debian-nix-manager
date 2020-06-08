{ config, lib, pkgs, ... }:

{
  imports = [
    ./vast.nix
    ./osquery
    ./elastic.nix
    ./postgresql.nix
    ./nix-serve.nix
    ./hydra.nix
    ./zookeeper.nix
    ./apache-kakfa.nix
    ./kibana.nix
    ./logstash.nix
    ./netdata.nix
    ./zeek.nix
  ];
}
