let
    nixpkgs = builtins.fetchTarball {
      url    = "https://github.com/GTrunSec/nixpkgs/tarball/39247f8d04c04b3ee629a1f85aeedd582bf41cac";
      sha256 = "1q7asvk73w7287d2ghgya2hnvn01szh65n8xczk4x2b169c5rfv0";
    };
    pkgs = (import nixpkgs) { };
in
pkgs.stdenv.mkDerivation {
  name = "zeek";
  nativeBuildInputs = [ pkgs.cmake pkgs.flex pkgs.bison pkgs.file pkgs.python38 ];
  buildInputs = [ pkgs.openssl pkgs.libpcap pkgs.zlib pkgs.curl pkgs.libmaxminddb pkgs.gperftools  pkgs.swig pkgs.rocksdb
                  pkgs.caf pkgs.git pkgs.python
                ];
  shellHook = ''
 # dir="zeek-3.0.3"
  dir="spicy"
  if [ -d "$dir" ]
  then
	echo "Skip download Zeek src."
  else
      #wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
      git clone https://github.com/zeek/spicy.git 
      #tar -xvf zeek-3.0.3.tar.gz
      fi
   # echo 'export PATH='$PATH >> path
   # sed -i 's|${pkgs.python}/bin|${pkgs.python38}/bin/|' path
   # export PATH="${pkgs.stdenv.lib.makeBinPath [ pkgs.python38.out ]}''${PATH:+:}$PATH"
   # export PYTHONPATH=${pkgs.python38}/${pkgs.python38.sitePackages}
   # bash path
   # cd spicy
   #rm -rf path

'';
}
