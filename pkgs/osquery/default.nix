{ stdenv, lib, fetchgit, pkgconfig, cmake, python3
, udev, audit, aws-sdk-cpp, cryptsetup, lvm2, libgcrypt, libarchive
, libgpgerror, libuuid, iptables, dpkg, lzma, bzip2, rpm
, beecrypt, augeas, libxml2, sleuthkit, yara, lldpd, gflags
, thrift, boost, rocksdb_lite, glog, gbenchmark, snappy
, openssl, file, doxygen, ccache, flex, bison, curl, ruby, google-gflags
, gtest, fpm, zstd, rdkafka, rapidjson, fetchurl, libelfin
, smartmontools, which, git, cscope, ctags, ssdeep
}:

let
  overrides = {
    # use older `lvm2` source for osquery, the 2.03 sourcetree
    # will break osquery due to the lacking header `lvm2app.h`.
    #
    # https://github.com/NixOS/nixpkgs/pull/51756#issuecomment-446035295
    # lvm2 = lvm2.overrideAttrs (old: rec {
    #   name = "lvm2-${version}";
    #   version = "2.02.183";
    #   src = fetchgit {
    #     url = "git://sourceware.org/git/lvm2.git";
    #     rev = "v${version}";
    #     sha256 = "1ny3srcsxd6kj59zq1cman5myj8kzw010wbyc6mrpk4kp823r5nx";
    #   };
    # });

    # use smartmontools fork to programatically retrieve SMART information.
    # https://github.com/facebook/osquery/pull/4133
    # smartmontools = smartmontools.overrideAttrs (old: rec {
    #   name = "smartmontools-${version}";
    #   version = "0.3.1";
    #   src = fetchFromGitHub {
    #     owner = "allanliu";
    #     repo = "smartmontools";
    #     rev = "v${version}";
    #     sha256 = "1i72fk2ranrky02h7nh9l3va4kjzj0lx1gr477zkxd44wf3w0pjf";
    #   };

      # Apple build fix doesn't apply here and isn't needed as we
      # only support `osquery` on Linux.
    #   patches = [];
    # });

    # dpkg 1.19.2 dropped api in `<dpkg/dpkg-db.h>` which breaks compilation.
    dpkg = dpkg.overrideAttrs (old: rec {
      name = "dpkg-${version}";
      version = "1.19.0.5";
      src = fetchurl {
        url = "mirror://debian/pool/main/d/dpkg/dpkg_${version}.tar.xz";
        sha256 = "1dc5kp3fqy1k66fly6jfxkkg7w6d0jy8szddpfyc2xvzga94d041";
      };
    });

    # filter out static linking configuration to avoid that the library will
    # be linked both statically and dynamically.
    gflags = gflags.overrideAttrs (old: {
      cmakeFlags = stdenv.lib.filter (f: (builtins.match ".*STATIC.*" f) == null) old.cmakeFlags;
    });
  };
in

stdenv.mkDerivation rec {
  pname = "osquery";
  version = "4.2.0";

  # this is what `osquery --help` will show as the version.
  OSQUERY_BUILD_VERSION = version;
  OSQUERY_PLATFORM = "NixOS;";

  src = fetchgit {
    url = "https://github.com/osquery/osquery";
    rev = "7ff9cf5a3f926197f80f0669f96fdeb2d7e9d90b";
    sha256 = "0g9pxc8qb1cbglbhllavpvq50d6xc84zqm4nv8yz3jcv3b9yswj4";
  };

  nativeBuildInputs = [ python3 which git cscope ctags cmake pkgconfig doxygen fpm ]
    ++ (with python3.pkgs; [ jinja2 
    thrift
    pexpect
    psutil
    six
    wheel
]);

  buildInputs = [
    udev
    audit
    aws-sdk-cpp
    lvm2
    libgcrypt
    libarchive
    libgpgerror
    libuuid
    iptables
    dpkg
    lzma
    bzip2
    rpm
    beecrypt
    augeas
    libxml2
    sleuthkit
    yara
    lldpd
    google-gflags
    thrift
    boost
    glog
    gbenchmark
    snappy
    openssl
    file
    cryptsetup
    gtest
    zstd
    rdkafka
    rapidjson
    rocksdb_lite
    libelfin
    ssdeep
    ccache
    flex
    bison
    curl
    ruby
    #overrides.smartmontools
  ];

  cmakeFlags = [ "-DSKIP_TESTS=1"
                 "-DOSQUERY_VERSION=4.2.0"
               ];

  preConfigure = ''
  '';

  meta = with lib; {
    description = "SQL powered operating system instrumentation, monitoring, and analytics";
    homepage = https://osquery.io/;
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ cstrahan ma27 ];
    broken = true;
  };
}
