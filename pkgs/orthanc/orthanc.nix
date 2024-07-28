{
  lib,
  pkgs,
  stdenv,
  fetchhg,
}:
let
  # trying to get dicom dict setup (not working)
  dcmtk-w-dict = pkgs.dcmtk.overrideAttrs {
    cmakeFlags = [
      "-DDCMTK_DEFAULT_DICT=builtin"
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "orthanc";
  version = "1.12.4";

  src = fetchhg {
    url = "https://orthanc.uclouvain.be/hg/orthanc/";
    rev = "023787ecaff2";
    sha256 = "16mgii4iki1024sd5fih2s9dwmxfxfivzqdawbwgl2s8pfgisgxf";
  };

  nativeBuildInputs = with pkgs; [
    gnumake
    cmake
    python3
    curl
    gtest
    protobuf
  ];

  buildInputs = with pkgs; [
    libgcc
    unzip
    sqlite
    openssl
    civetweb
    libjpeg
    libpng
    lua
    pugixml
    jsoncpp
    libuuid
    boost
    #dcmtk-w-dict
    dcmtk # implements the dicom standard
    #sqlitecpp
    #gflags
    #locale
  ];

  cmakeFlags = [
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
    "-DCMAKE_BUILD_TYPE=Debug"
  ];

  configurePhase = ''
    mkdir Build
    cd ./Build
    cmake ../OrthancServer/
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp * $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Orthanc is a lightweight DICOM server for medical imaging";
    homepage = "https://www.orthanc-server.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      jodogne
      "Alain Mazy"
    ];
    platforms = [
      "x86_64-linux"
    ];
  };
})
