{
  lib,
  pkgs,
  stdenv,
  fetchhg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "orthanc-sdk";
  version = "1.12.6";
  src = fetchhg {
    url = "https://orthanc.uclouvain.be/hg/orthanc/";
    rev = "6679ca3cb466";
    sha256 = "sha256-Bz8LI4SrovpuXlv7uXdagY9QVzBwZM0dodCKp50X8Nw=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    python3
  ];

  buildInputs = with pkgs; [
    jsoncpp
    boost
    dcmtk
    libpng
    libjpeg
    sqlite
    pugixml
    libuuid
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
    "-DORTHANC_FRAMEWORK_SOURCE=path"
    "-DORTHANC_FRAMEWORK_ROOT=./OrthancFramework/Sources"
    "-DBUILD_SHARED_LIBRARY=ON"
  ];

  configurePhase = ''
    mkdir Build
    cd ./Build
    cmake ../OrthancFramework/SharedLibrary $cmakeFlags
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,include/orthanc-sdk}

    # Install library
    cp ./libOrthancFramework.so* $out/lib/

    # Install headers
    cp -r ../OrthancFramework/Sources/* $out/include/orthanc-sdk/
    cp ./OrthancFramework.h $out/include/orthanc-sdk/

    runHook postInstall
  '';

  meta = {
    description = "SDK for building Orthanc plugins and related applications";
    homepage = "https://www.orthanc-server.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dvcorreia ];
    platforms = [ "x86_64-linux" ];
  };
})
