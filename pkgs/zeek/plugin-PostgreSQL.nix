with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "zeek-PostgreSQL";
  nativeBuildInputs = [ cmake  ];
  buildInputs = [ git postgresql libpcap ];
  shellHook = ''
  dir="zeek-3.0.3"
  if [ -d "$dir" ]
  then
	echo "Skip download Zeek src."
  else
    wget https://old.zeek.org/downloads/zeek-3.0.3.tar.gz
      tar -xvf zeek-3.0.3.tar.gz
fi
  git clone https://github.com/0xxon/zeek-postgresql.git
  cd zeek-postgresql
  ./configure --zeek-dist=../zeek-3.0.3
  '';
}
