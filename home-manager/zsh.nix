{ config, lib, pkgs, ... }:
let
    home_directory = builtins.getEnv "HOME";
in
{
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "z" "history-substring-search"];
      theme = "robbyrussell";
    };
    history = {
      share = true;
      path = config.programs.zsh.dotDir + "/.zsh_history";
      save = 10000000;
      ignoreDups = true;
      extended = true;
      size = 10000000;
    };
    shellAliases = with pkgs; {
      l     = "exa -lah";
      f     = "rg --files";
      E     = "env SUDO_EDITOR=\"emacsclient\" sudo -e";
      em    = "emacs";
      cp    = "cp -i";
      mv    = "mv -i";
      overlay-go   = "cd ~/.config/nixpkgs/nixos/overlays/go";
      overlay-python   = "cd ~/.config/nixpkgs/nixos/overlays/python";
      overlay-custom   = "cd ~/.config/nixpkgs/nixos/overlays/custom";
      ag0   = "rg --max-depth=1";
      pcat  = "${python3Packages.pygments}/bin/pygmentize";
      so    = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*usb/{if (a != \"\") print a;} {a=$NF}\\\')";
      si    = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*pci/{if (a != \"\") print a;} {a=$NF}\\\')";
    };

    initExtra = builtins.readFile "${home_directory}/.config/nixpkgs/dotfiles/keys.sh" + builtins.readFile "${home_directory}/.config/nixpkgs/dotfiles/zshrc" + ''
        SPACESHIP_TIME_SHOW=true
        SPACESHIP_EXIT_CODE_SHOW=true
        SPACESHIP_VI_MODE_SHOW=false
        SPACESHIP_BATTERY_THRESHOLD=30
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=238'
        setopt HIST_IGNORE_ALL_DUPS
'';
    
    plugins =
      [
       {
         name = "spaceship";
         file = "spaceship.zsh";
         src = pkgs.fetchgit {
           url = "https://github.com/denysdovhan/spaceship-prompt";
           rev = "v3.11.1";
           sha256 = "0habry3r6wfbd9xbhw10qfdar3h5chjffr5pib4bx7j4iqcl8lw8";
         };
       }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma";
            repo = "fast-syntax-highlighting";
            rev = "303eeee81859094385605f7c978801748d71056c";
            sha256 = "0y0jgkj9va8ns479x3dhzk8bwd58a1kcvm4s2mk6x3n19w7ynmnv";
          };
        }
        {
          name = "fzf-z";
          src = pkgs.fetchFromGitHub {
            owner = "andrewferrier";
            repo = "fzf-z";
            rev = "2db04c704360b5b303fb5708686cbfd198c6bf4f";
            sha256 = "1ib98j7v6hy3x43dcli59q5rpg9bamrg335zc4fw91hk6jcxvy45";
          };
        }
      ];
  };
}
