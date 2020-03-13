{ config, pkgs, ... }:

{
home.file = {
  # This has been integrated into direnv stdlib
   ".nix-direnv".source = pkgs.fetchFromGitHub {
     owner = "nix-community";
     repo = "nix-direnv";
     rev = "f9889758694bdfe11251ac475d78a93804dbd93c";
     sha256 = "16mpc6lidmn6annyl4skdixzx7syvwdj9c5la0sidg57l8kh1rqd";
   };
   ".direnvrc".text = ''
      source $HOME/.nix-direnv/direnvrc
    '';
};
}
