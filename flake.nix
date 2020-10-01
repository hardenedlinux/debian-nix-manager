{
  description = "hardenedlinux debian home-manager profile";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/684d5d27136f154775c95005dcce2d32943c7c9e";
    master.url = "nixpkgs/703f052de185c3dd1218165e62b105a68e05e15f";
    hardenedlinux-pkgs.url = "github:hardenedlinux/nixpkgs-hardenedlinux/master";
    emacs-overlay.url = "github:nix-community/emacs-overlay/9f0ac65857f41e134389317c6463cf2df6f05f75";

    detect-ransomware-filenames = {
      url = "github:corelight/detect-ransomware-filenames";
      flake = false;
    };

    spl-spt = {
      url = "github:GTrunSec/spl-spt";
      flake = false;
    };

    zeek-EternalSafety = {
      url = "github:lexibrent/zeek-EternalSafety";
      flake = false;
    };

    IRC-Zeek-package = {
      url = "github:stratosphereips/IRC-Zeek-package";
      flake = false;
    };
  };

  #outputs = inputs@{ self, nixpkgs, hardenedlinux-pkgs, master, flake-utils, emacs-overlay }:
  outputs = inputs: with builtins;let
      python-packages-overlay = (import "${inputs.hardenedlinux-pkgs}/nix/python-packages-overlay.nix");
      packages-overlay = (import "${inputs.hardenedlinux-pkgs}/nix/packages-overlay.nix");
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
            devShell = import ./shell.nix { inherit pkgs; };
          }
        )
    );
  }
