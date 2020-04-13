with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "zeek-PostgreSQL";
  nativeBuildInputs = [ cmake  ];
  buildInputs = [ git rdkafka openssl libpcap];
  shellHook = ''
  dir="zeek-3.0.3"
  if [ -d "$dir" ]
  then
	echo "Skip download Zeek src."
  else
    wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
      tar -xvf zeek-3.0.3.tar.gz
fi
#  git clone https://github.com/apache/metron-bro-plugin-kafka.git --depth=1
  cd metron-bro-plugin-kafka
  ./configure --bro-dist=../zeek-3.0.3
  '';
}
