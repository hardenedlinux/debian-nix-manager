with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "zeek-http2";
  nativeBuildInputs = [ cmake  ];
  buildInputs = [ git nghttp2 brotli libpcap zlib openssl ];
  shellHook = ''
  dir="zeek-3.0.3"
  if [ -d "$dir" ]
  then
	echo "Skip download Zeek src."
  else
    wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
      tar -xvf zeek-3.0.3.tar.gz
fi
  git clone https://github.com/MITRECND/bro-http2
  cd bro-http2 &&  ./configure --bro-dist=../zeek-3.0.3
  '';
}
