{ config, pkgs, lib, ... }:

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

   ".myscript/eaf".source =pkgs.fetchFromGitHub {
     owner = "manateelazycat";
     repo = "emacs-application-framework";
     rev = "320840214bcb3cd2f5a0729adbe09a0ff56c8148";
     sha256 = "0f4wra2w78nlbfgnwlnpmn2i73lrv4kqcsnfs86asmvf3g26d5jy";
   };


   ".myscript/snails".source =pkgs.fetchFromGitHub {
     owner = "manateelazycat";
     repo = "snails";
     rev = "7e83f3822c00ee496cce42cf69331436cb3b1379";
     sha256 = "1448d333vny2gq4jaldl9zy62jy81ih5166l0aak3p49vv8g38bz";
   };

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
