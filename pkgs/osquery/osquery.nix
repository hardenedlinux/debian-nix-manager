with import <nixpkgs> {};
let
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;

  python = python3Packages.python.withPackages( ps: with ps; [
    jinja2
    osquery
    thrift
    timeout_decorator
    pexpect
    psutil
    six
    wheel
  ]);
in
stdenv.mkDerivation {
  name = "osquery-nix-shell";
  nativeBuildInputs = [ cmake  ];
  buildInputs = [ git cmake udev audit aws-sdk-cpp cryptsetup lvm2 libgcrypt libarchive
                  libgpgerror libuuid iptables dpkg lzma lz4 bzip2 rpm
                  beecrypt augeas libxml2 sleuthkit yara lldpd google-gflags
                  thrift boost rocksdb_lite cpp-netlib glog gbenchmark snappy
                  openssl linenoise-ng file doxygen devicemapper
                  gtest sqlite curl ruby clang bison flex ccache];
  shellHook = ''
# wget https://github.com/osquery/osquery-toolchain/releases/download/1.0.0/osquery-toolchain-1.0.0.tar.xz
# sudo tar xvf osquery-toolchain-1.0.0.tar.xz -C /usr/local

# # Download and install a newer CMake
# wget https://github.com/Kitware/CMake/releases/download/v3.14.6/cmake-3.14.6-Linux-x86_64.tar.gz
#      sudo tar xvf cmake-3.14.6-Linux-x86_64.tar.gz -C /usr/local --strip 1
#   git clone https://github.com/osquery/osquery
  cd osquery-4.2.0
  mkdir build
  cd build
   cmake -DOSQUERY_TOOLCHAIN_SYSROOT=/usr/local/osquery-toolchain ..
  '';
}
