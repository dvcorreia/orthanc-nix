{
  lib,
  pkgs,
  stdenv,
  fetchhg,
  osxTarget ? "14.0",
}:

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
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.DarwinTools
    darwin.xcode
  ];

  buildInputs = with pkgs; [
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
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    libgcc
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DDCMTK_DICTIONARY_DIR=${pkgs.dcmtk}/share/dcmtk-${pkgs.dcmtk.version}/"
    "-DBUILD_CONNECTIVITY_CHECKS=OFF"
    "-DDCMTK_LIBRARIES=oflog;ofstd"
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-GXcode"
    "-DCMAKE_OSX_DEPLOYMENT_TARGET=${osxTarget}"
  ];

  configurePhase = ''
    xcode-select --print-path
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
      "aarch64-darwin"
    ];
  };
})
