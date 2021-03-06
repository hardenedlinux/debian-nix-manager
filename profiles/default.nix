{ ... }:
{
  imports = [
    ./programs
    ./elk
    ./services
    ./home-file.nix
    ./core-packages.nix
    ./misc-packages.nix
    ./hosts
    ./python-packages.nix
    ./shell-env.nix
  ];
}
