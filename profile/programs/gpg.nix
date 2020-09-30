{...}:
{
  programs.gpg = {
    enable = true;
    settings = {
      #default-key = "";
      cert-digest-algo = "SHA512";
      disable-cipher-algo = "3DES";
      default-recipient-self = true;
      use-agent = true;
      with-fingerprint = true;
    };
  };
}
