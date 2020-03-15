with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "zeek";
  nativeBuildInputs = [ cmake flex bison file ];
  buildInputs = [ openssl libpcap zlib curl libmaxminddb gperftools python swig rocksdb];
  shellHook = ''
  wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
  tar -xvf zeek-3.0.3.tar.gz
  cd zeek-3.0.3/
  ./configure
  make
  sudo make install
  '';
}
