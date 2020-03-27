{ stdenv, fetchurl, cmake, udev, audit, aws-sdk-cpp, cryptsetup, lvm2, libgcrypt, libarchive
,libgpgerror, libuuid, iptables, dpkg, lzma, lz4, bzip2, rpm, git
,beecrypt, augeas, libxml2, sleuthkit, yara, lldpd, google-gflags
,thrift, boost, rocksdb_lite, cpp-netlib, glog, gbenchmark, snappy
,openssl, linenoise-ng, file, doxygen, devicemapper
,gtest, sqlite, curl, ruby, clang, bison, flex, ccache, python3, which
}:

stdenv.mkDerivation rec {
  pname = "osquery";
  version = "4.2.0";

  src = fetchurl {
    url = "https://pkg.osquery.io/deb/osquery_4.2.0_1.linux.amd64.deb";
    sha256 = "1i8ac8i64cc80sp18gl18m46rnz6sc041r8acsrskc7aq6rbxd3n";
  };

  phases = [ "installPhase" ];

  nativeBuildInputs = [ python3 which ]
    ++ (with python3.pkgs; [ jinja2 
    thrift
    pexpect
    psutil
    six
    wheel
]);

  buildInputs = [ git cmake udev audit aws-sdk-cpp cryptsetup lvm2 libgcrypt libarchive
                  libgpgerror libuuid iptables dpkg lzma lz4 bzip2 rpm
                  beecrypt augeas libxml2 sleuthkit yara lldpd google-gflags
                  thrift boost rocksdb_lite cpp-netlib glog gbenchmark snappy
                  openssl linenoise-ng file doxygen devicemapper
                  gtest sqlite curl ruby clang bison flex ccache];


  installPhase = ''
    mkdir -p $out/bin
    dpkg-deb -x $src $out
   ln -s $out/usr/bin/* $out/bin/
  '';

  meta = {
    description = "SQL powered operating system instrumentation, monitoring, and analytics";
    homepage = https://osquery.io/;
    license =  stdenv.lib.licenses.bsd3;
    platforms =  stdenv.lib.platforms.linux;
    maintainers = with  stdenv.lib.maintainers; [ ];
    broken = true;
  };
}
