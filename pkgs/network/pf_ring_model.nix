with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "PF_RING";
  nativeBuildInputs = [ cmake ];
  buildInputs = [ bison flex ];
  shellHook = ''
      dir="PF_RING-7.6.0"
      if [ -d "$dir" ]
      then
      echo "Skip download PF_RING src."
      echo "if you first time running PF_RING of nix-shell
      sudo apt-get install linux-headers-4.19.0-8-amd64"
      else
        wget https://github.com/ntop/PF_RING/archive/7.6.0.tar.gz
          tar -xvf 7.6.0.tar.gz
    fi
      cd PF_RING-7.6.0/kernel
  '';
}
