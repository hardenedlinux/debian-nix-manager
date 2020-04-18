{ pkgs ? import <nixpkgs> {} }:
let
  preConfigure = (import ./shell.nix);
in
pkgs.stdenv.mkDerivation rec {
  pname = "zeek";
  version = "3.0.5";
  
  src = pkgs.fetchurl {
    url = "https://old.zeek.org/downloads/zeek-${version}.tar.gz";
    sha256 = "031q56hxg9girl9fay6kqbx7li5kfm4s30aky4s1irv2b25cl6w2";
  };

  nativeBuildInputs = [ pkgs.cmake pkgs.flex pkgs.bison pkgs.file];
  buildInputs = [ pkgs.openssl pkgs.libpcap pkgs.zlib pkgs.curl pkgs.libmaxminddb
                  pkgs.gperftools pkgs.python pkgs.swig pkgs.rocksdb
                  ##plugin dep
                  pkgs.rdkafka pkgs.postgresql pkgs.nghttp2 pkgs.brotli
                  ] ;
  # Indicate where to install the python bits, since it can't put them in the "usual"
  # locations as those paths are read-only.
  
  inherit preConfigure;

  cmakeFlags = [
    "-DPY_MOD_INSTALL_DIR=${placeholder "out"}/${pkgs.python.sitePackages}"
    "-DENABLE_PERFTOOLS=true"
    "-DINSTALL_AUX_TOOLS=true"
  ];

  enableParallelBuilding = true;
  meta = with pkgs.stdenv.lib; {
    description = "Powerful network analysis framework much different from a typical IDS";
    homepage = https://www.bro.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ pSub ];
    platforms = with platforms; linux;
  };
}
