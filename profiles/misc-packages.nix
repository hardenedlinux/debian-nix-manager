{ config, pkgs, ... }:
{
  home.packages = with pkgs;[
    aria2
    graphviz
    wakatime
    xapian
  ];

}
