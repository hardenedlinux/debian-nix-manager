let
    nixpkgs = builtins.fetchTarball {
      url    = "https://github.com/GTrunSec/nixpkgs/tarball/39247f8d04c04b3ee629a1f85aeedd582bf41cac";
      sha256 = "1q7asvk73w7287d2ghgya2hnvn01szh65n8xczk4x2b169c5rfv0";
    };
    pkgs = (import nixpkgs) { };
in
pkgs.stdenv.mkDerivation {
  name = "zeek";
  nativeBuildInputs = [ pkgs.cmake pkgs.flex pkgs.bison pkgs.file ];
  buildInputs = [ pkgs.openssl pkgs.libpcap pkgs.zlib pkgs.curl pkgs.libmaxminddb pkgs.gperftools pkgs.python pkgs.swig pkgs.rocksdb pkgs.caf];
  shellHook = ''
  dir="zeek-3.0.3"
  if [ -d "$dir" ]
  then
	echo "Skip download Zeek src."
  else
      wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
      tar -xvf zeek-3.0.3.tar.gz
fi
  cd zeek-3.0.3/
  ./configure
  '';
}
