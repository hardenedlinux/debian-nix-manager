{...}:
{
    programs.ssh = {
    enable      = true;
    compression = true;
    controlMaster  = "auto";
    controlPersist = "1h";
    extraConfig    = ''
    BatchMode no
    AddKeysToAgent yes
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 10
    EscapeChar none
    IdentitiesOnly yes
    '';
    };
 }
