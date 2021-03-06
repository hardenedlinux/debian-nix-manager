{ stdenv
, bison
, fetchFromGitHub
, flex
, hiredis
, zeromq
}:
let
  version = "7.6.0";
in
stdenv.mkDerivation {
  name = "pf-ring-${version}";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = "PF_RING";
    rev = "266e8a48a4e731122d3975b213543fc30e912f96";
    sha256 = "1sbhxpafcqi7081ngf4ljs96ysddgmk9ar8wmr5d9i0i63ifi8hc";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    hiredis
    zeromq
  ];

  postPatch = ''
    sed -i 's, lex$, flex,' userland/nbpf/Makefile.in
  '';

  preConfigure = ''
    cd userland/lib
  '';

  configureFlags = [
    "--enable-redis"
    "--enable-zmq"
  ];

  postInstall = ''
    cp -r ../../kernel/ "$out/include"
  '';

  # Parallel building is broken
  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms; linux;
  };
}
