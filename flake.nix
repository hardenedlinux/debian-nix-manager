{
  description = "hardenedlinux debian home-manager profile";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/684d5d27136f154775c95005dcce2d32943c7c9e";
    master.url = "nixpkgs/703f052de185c3dd1218165e62b105a68e05e15f";
    hardenedlinux-pkgs.url = "github:hardenedlinux/nixpkgs-hardenedlinux/1d884a7ddd6aa0d04fa05a5f6efd11e1d1d25552";
    emacs-overlay.url = "github:nix-community/emacs-overlay/9f0ac65857f41e134389317c6463cf2df6f05f75";
  };

  outputs = inputs@{ self, nixpkgs, hardenedlinux-pkgs, master, flake-utils, emacs-overlay }:
    {
      python-packages-overlay = (import "${hardenedlinux-pkgs}/nix/python-packages-overlay.nix");
      packages-overlay = (import "${hardenedlinux-pkgs}/nix/packages-overlay.nix");
    }
    //
    (flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                self.python-packages-overlay
                self.packages-overlay
          ];
        };
          in
          {
            devShell = import ./shell.nix { inherit pkgs; };
          }
        )
    );
  }
