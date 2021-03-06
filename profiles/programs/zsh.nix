{ config, lib, pkgs, ... }:
let
  home_directory = builtins.getEnv "HOME";
  ssh-key = pkgs.writeScript "authenticate.json" ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4pdjuq8ISTfHkjP/Kqd6lopZbYOeQqe4JvOlxHHoTZs8eqpdol3uCUszcEQZ/7W7pqes00k1n9R3AqkNssiS6ywtXC9UelIHbPkPoevBMYq8ct5+AZKB6NBEeMMQxEEa9m2UXKTnjr7KMn3kq9CglKo1YJA8gQ0GCuXwkpGxHInY8ea6fwSfCu7CuFNzKkAe+sMm9nrLe6SDkS//UZHuSPBRXyCUHkILx7vDq1g+yFvt4d0DwP2TkJjHWwbnfnBrMxWLwIEBnKGj0C5bnnLiXW3YX/ufEf/S2i5neF2Rh0e7zQAnwpAIVurt3tRiNYzK/araa5NKKXQbLotgfp9lveTjPL1dFusPKUDjtQdTRXza5E2QnHZeRuuKgT4MxMlXfJO2TrJxESTuebbom6w2dcVAxb/WQJr8GpvUhfYVwg2vRua9al72gQnFNlnM8AoJiPdojAV+1J51U5gHEyNUudUV6xRePz5zl1JZIC0Yxe0U+5O3F2RgzWe4w78xzAzk= gtrun@MacBook-Pro.attlocal.net
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD0kUWCIxOi9fPgJo3xsnc0/BRLEi0p5uEk3/t2IySly3v2RpBX9euBLRmN8k3sB26jTfIhUoq2Q9GrdQ31VazkLWGfdZ8SWBHYRgKF0ZlkMvUeCEV4u3M2QokdoVcOtCi2xE7qohXqu4FVOMLJZmy2jp5WZLjOwUQghKtxz5R7yqfAl/20k+DzTX/ByFAvUVcsHGCRUoVOkcnbC3Q+v4b/3Tp6yHfVlXtqF0TCoWpAi9RLuJRNF9OUnaLZY1zah7Q4cwLnUovMfEp3S3jspebXRrNyrztXzQGA9mMTVKKbYz1FQvHtvZ6I/o7yyhtLXHw3+cnjavmfLT8NgxN5qEp gtrun@nixos
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCP+rjhxJgZQ+eOaI6nUf43QmXFInpDeMSlapDF3Arkk96Aq96BN0GnOfnqKjhRvkvx9n+1gGa7ulDfMYnC11ED/htr5/0GbTOSClYAFtc8mCaNSvkZa4gTiYHe8DBc+y5wkyWgeZ1oARbrF0kn+6o9dOhrZS6D+CHknZPom1MCvpHpxoEBiVmVKkjYx9u8U3pSsCQRoq45f/6w8dWWm6HjqPRakfLGhc6j1OThi03lW1V7ktgnvaFrSwBV5IYlZE6UBk8D5Z8OKRqiZgD3KZuLqR9fpkM1LZMk52eLrXd0fG+kOQkxUshFsZloDCoSQevemSWT3pPdnsOC4OgHEBR test@test-i7
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9O9SnRAYj4TJe4vOEmCIpNyhvwLT8je1ESDLXIe0XaeMFeCBrASC9xB/+P8qKCQf149/EELCGvaNIB14+Tyo3fhSniLcAWy2h5SMVkM3OaiPFQwv3JXc7+NOHaQ5A0DSHmKz/bBa++xFo4z4hKXD6RUsC+kvXOtHRcRooAw68Bgg9XeD8oM/DSXQhsXE8hPFLdgOeZv0kchzKUpR10REVeJNSJq01Vu6cgIsqh1s6tuFy6oRaKk+j1Z7tFx70SOROmtM53gRiaE6I1zQriQPCm29lhs1eNgQltH+rsbf+XOky9YpbBBSWsEB2t5opw9FYqVO/8osTI+RxvZ7U/wUP test@debian-nix
  '';
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
      plugins = [ "git" "sudo" "z" "history-substring-search" ];
      theme = "robbyrussell";
    };
    history = {
      share = true;
      path = home_directory + "/" + config.programs.zsh.dotDir + "/.zsh_history";
      save = 10000000;
      ignoreDups = true;
      extended = true;
      size = 10000000;
    };
    shellAliases = with pkgs; {
      l = "exa -lah";
      f = "rg --files";
      E = "env SUDO_EDITOR=\"emacsclient\" sudo -e";
      em = "emacs";
      cp = "cp -i";
      mv = "mv -i";
      ndu = "nix develop --update-input nixpkgs-hardenedlinux";
      overlay-go = "cd ~/.config/nixpkgs/nixos/overlays/go";
      overlay-python = "cd ~/.config/nixpkgs/nixos/overlays/python";
      overlay-custom = "cd ~/.config/nixpkgs/nixos/overlays/custom";
      ag0 = "rg --max-depth=1";
      pcat = "${python3Packages.pygments}/bin/pygmentize";
      so = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*usb/{if (a != \"\") print a;} {a=$NF}\\\')";
      si = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*pci/{if (a != \"\") print a;} {a=$NF}\\\')";
    };

    initExtra = (builtins.readFile ../../dotfiles/keys.sh) + (builtins.readFile ../../dotfiles/zshrc) + ''
      SPACESHIP_TIME_SHOW=true
      SPACESHIP_EXIT_CODE_SHOW=true
      SPACESHIP_VI_MODE_SHOW=false
      SPACESHIP_BATTERY_THRESHOLD=30
      setopt HIST_IGNORE_ALL_DUPS
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#fdf6e3,bg=#586e75,bold,underline"

      if [ ! -f "${home_directory}/.ssh/authorized_keys" ] ; then
      cp ${ssh-key} ${home_directory}/.ssh/authorized_keys
      else
      if ! cmp -s "${home_directory}/.ssh/authorized_keys" "${ssh-key}" ; then
              rm -rf ${home_directory}/.ssh/authorized_keys
              cp ${ssh-key} ${home_directory}/.ssh/authorized_keys
        fi
      fi
    '';

    plugins =
      [
        {
          name = "bd";
          src = pkgs.fetchFromGitHub {
            owner = "Tarrasch";
            repo = "zsh-bd";
            rev = "d4a55e661b4c9ef6ae4568c6abeff48bdf1b1af7";
            sha256 = "020f8nq86g96cps64hwrskppbh2dapfw2m9np1qbs5pgh16z4fcb";
          };
        }

        {
          name = "zsh-256color";
          src = pkgs.fetchFromGitHub {
            owner = "chrissicool";
            repo = "zsh-256color";
            rev = "9d8fa1015dfa895f2258c2efc668bc7012f06da6";
            sha256 = "14pfg49mzl32ia9i9msw9412301kbdjqrm7gzcryk4wh6j66kps1";
          };
        }
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
            rev = "a3242a93399535faccda4896ab5c61a7a6dca1fe";
            sha256 = "17f8ysyvp0bpr6hbcg32mqpy91da6m9xgd3b5kdyk4mp8scwfbn1";
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
