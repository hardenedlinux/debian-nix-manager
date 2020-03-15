with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "zeek";
  nativeBuildInputs = [ cmake flex bison file ];
  buildInputs = [ openssl libpcap zlib curl libmaxminddb gperftools python swig rocksdb ];
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
