{
  description = "hardenedlinux debian home-manager profile";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/362477fdf726ed1dff33eadda8b99b257b46e085";
    master.url = "nixpkgs/master";
    home = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs-hardenedlinux = { url = "github:hardenedlinux/nixpkgs-hardenedlinux"; flake = false; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay/493c870ffafe7bec37d5233079d4d380ac1837d4"; };
    zeek-nix = { url = "github:hardenedlinux/zeek-nix"; inputs.nixpkgs.follows = "nixpkgs"; };

    detect-ransomware-filenames = { url = "github:corelight/detect-ransomware-filenames"; flake = false; };
    spl-spt = { url = "github:GTrunSec/spl-spt"; flake = false; };
    zeek-EternalSafety = { url = "github:lexibrent/zeek-EternalSafety"; flake = false; };
    IRC-Zeek-package = { url = "github:stratosphereips/IRC-Zeek-package"; flake = false; };
  };

  #outputs = inputs@{ self, nixpkgs, hardenedlinux-pkgs, master, flake-utils, emacs-overlay }:
  outputs = inputs: with builtins;let
    python-packages-overlay = (import "${inputs.nixpkgs-hardenedlinux}/nix/python-packages-overlay.nix");
    packages-overlay = (import "${inputs.nixpkgs-hardenedlinux}/nix/packages-overlay.nix");
  in
  (inputs.flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            python-packages-overlay
            packages-overlay
          ];
        };
      in
      {
        devShell = import ./devShell.nix { inherit pkgs; pkgsChannel = inputs.nixpkgs; homeChannel = inputs.home; };
      }
    )
  );
}
