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

  # ".emacs.d".source = pkgs.fetchFromGitHub {
  #   owner = "GTrunSec";
  #   repo = "doom-emacs";
  #   rev = "728fbc498229be1f63d811c2eb29e3661da58a9a";
  #   sha256 = "044qr82xndx3xnz2mlfma469picla5jkzrswyj8xghd34jxxdawq";
  # };
  
   ".config/pet".source = ./dotfiles/pet;
   ".wakatime.cfg".text = ''
    [settings]
    debug=true
    verbose = true
    offline = true
    api_key = dff3f4c8-2b39-4514-b9c7-2f3a14c928c9
    exclude = ^COMMIT_EDITMSG$
      ^TAG_EDITMSG$
      ^/var/(?!www/).*
      ^/etc/
      ^__pycache__
      ^/zeek
    include =
    include_only_with_project_file = false
    [projectmap]
       ^~/.config/nixpkgs(\d+)/ = project{0}
    [git]
    disable_submodules = false
    '';

};

}
