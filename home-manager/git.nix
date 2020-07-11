{pkgs, ...}:
{
  programs.git = {
    enable = true;
    userName = "gtrunsec";
    userEmail = "gtrunsec@hardenedlinux.org";
#    signing.key = "20C828B69E5458A0";
#    signing.signByDefault = true;
    ignores = [ ".projectile" ".indium.json" ".ccls-cache"
                ".Rhistory" ".notdeft*" ".auctex-auto" "__pycache__"
                "vast.db"
                ".ipynb_checkpoints"
                "org-roam.db"
              ];
    extraConfig = {
      pull = {
        rebase = true;
      };
      merge = {
        ff = "only";
      };
      rebase = {
        autostash = true;
      };
      http = {
        sslVerify = true;
      };
    };
  };
}
