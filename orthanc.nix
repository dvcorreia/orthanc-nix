{
  lib,
  pkgs,
  stdenv,
  fetchhg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "orthanc";
  version = "1.12.6";

  src = fetchhg {
    url = "https://orthanc.uclouvain.be/hg/orthanc/";
    rev = "6679ca3cb466";
    sha256 = "sha256-Bz8LI4SrovpuXlv7uXdagY9QVzBwZM0dodCKp50X8Nw=";
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
    dcmtk # implements the dicom standard
    #sqlitecpp
    #gflags
    locale
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DDCMTK_DICTIONARY_DIR=${pkgs.dcmtk}/share/dcmtk-${pkgs.dcmtk.version}/"
    "-DBUILD_CONNECTIVITY_CHECKS=OFF"
    "-DDCMTK_LIBRARIES=oflog;ofstd"
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
  ];

  configurePhase = ''
    mkdir Build
    cd ./Build
    cmake $cmakeFlags ../OrthancServer/
  '';

  doCheck = false; # ISSUE: the file /etc/localtime must be present on the filesystem
  checkPhase = ''
    ./UnitTests
  '';

  buildPhase = ''
    make -j`nproc --all`
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./Orthanc $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Orthanc is a lightweight DICOM server for medical imaging";
    homepage = "https://www.orthanc-server.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      dvcorreia
    ];
    platforms = [
      "x86_64-linux"
    ];
  };
})
