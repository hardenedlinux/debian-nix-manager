{stdenv, fetchurl, cmake, flex, bison, openssl, libpcap, zlib, file, curl
, libmaxminddb, gperftools, python, swig, rocksdb, rdkafka, postgresql, pkgs, system-sendmail, caf, fetchpatch}:
let
  preConfigure = (import ./shell.nix);
  metron-bro-plugin-kafka = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).metron-bro-plugin-kafka;
  zeek-postgresql = pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile ./zeek-plugin.json)).zeek-postgresql;
  install_plugin = pkgs.writeScript "install_plugin" (import ./install_plugin.nix { });
in
stdenv.mkDerivation rec {
  pname = "zeek";
  version = "3.0.5";
  confdir = "/var/lib/${pname}";
  src = fetchurl {
    url = "https://old.zeek.org/downloads/zeek-${version}.tar.gz";
    sha256 = "031q56hxg9girl9fay6kqbx7li5kfm4s30aky4s1irv2b25cl6w2";
  };

  nativeBuildInputs = [ cmake flex bison file ];
  buildInputs = [ openssl libpcap zlib curl libmaxminddb gperftools python swig rocksdb system-sendmail caf 
                  rdkafka postgresql
                ];
  # Indicate where to install the python bits, since it can't put them in the "usual"
  # locations as those paths are read-only.
  ZEEK_DIST = "${placeholder "out"}";

  patches = [ ./zeekctl.patch ] ++ stdenv.lib.optionals stdenv.cc.isClang [
    # Fix pybind c++17 build with Clang. See: https://github.com/pybind/pybind11/issues/1604
    (fetchpatch {
      url = "https://github.com/pybind/pybind11/commit/759221f5c56939f59d8f342a41f8e2d2cacbc8cf.patch";
      sha256 = "0l8z7d7chq1awd8dnfarj4c40wx36hkhcan0702p5l89x73wqk54";
      extraPrefix = "aux/broker/bindings/python/3rdparty/pybind11/";
      stripLen = 1;
    })    
  ];

  inherit preConfigure;

  cmakeFlags = [
    "-DPY_MOD_INSTALL_DIR=${placeholder "out"}/${python.sitePackages}"
    "-DENABLE_PERFTOOLS=true"
    "-DINSTALL_AUX_TOOLS=true"
    "-DINSTALL_ZEEKCTL=true"
    "-DZEEK_ETC_INSTALL_DIR=${placeholder "out"}/etc"
    "-DCAF_ROOT_DIR=${caf}"
    "-DZEEK_SPOOL_DIR=${confdir}/spool"
    "-DZEEK_LOG_DIR=${confdir}/logs"
  ];

  postFixup = ''
        substituteInPlace $out/etc/zeekctl.cfg \
         --replace "CfgDir = $out/etc" "CfgDir = ${confdir}/etc"
         echo "scriptsdir = ${confdir}/scripts" >> $out/etc/zeekctl.cfg
         echo "helperdir = ${confdir}/scripts/helpers" >> $out/etc/zeekctl.cfg
         echo "postprocdir = ${confdir}/scripts/postprocessors" >> $out/etc/zeekctl.cfg
         ###INSTALL Zeek PLugins
         bash ${install_plugin} metron-bro-plugin-kafka ${metron-bro-plugin-kafka} ${version}
         bash ${install_plugin} zeek-postgresql ${zeek-postgresql} ${version}
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Powerful network analysis framework much different from a typical IDS";
    homepage = https://www.bro.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ pSub ];
    platforms = with platforms; linux;
  };
}
