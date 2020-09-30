{ ... }:

{
  imports = [
    ./git.nix
    ./tmux.nix
    ./doom-emacs.nix
    ./zsh.nix
    ./gpg.nix
  ];

  programs.htop.enable = true;
  programs.bat.enable = true;

}
