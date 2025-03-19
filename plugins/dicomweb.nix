{
  lib,
  pkgs,
  stdenv,
  fetchhg,
  fetchurl,
  orthanc-sdk,
}:

let
  bootstrap-file = fetchurl {
    url = "https://orthanc.uclouvain.be/downloads/third-party-downloads/bootstrap-5.3.3.zip";
    sha256 = "sha256-VdfxznlQQK+4MR3wnSnQ00ZIQAweqrstCi7SIWs9sF0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "orthanc-dicomweb";
  version = "1.18";

  src = fetchhg {
    url = "https://orthanc.uclouvain.be/hg/orthanc-dicomweb/";
    rev = "9535bcd7fa8b";
    sha256 = "sha256-ee271Fcu8yi1gZpTWrCuqhsBdFcPR/JK/fsnJg8PwIc=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    python3
    unzip
    gtest
  ];

  buildInputs = with pkgs; [
    orthanc-sdk
    jsoncpp
    boost
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
    "-DORTHANC_FRAMEWORK_SOURCE=system"
    "-DORTHANC_FRAMEWORK_ROOT=${orthanc-sdk}/include/orthanc-sdk"
    "-DORTHANC_FRAMEWORK_LIBRARIES=${orthanc-sdk}/lib/libOrthancFramework.so"
  ];

  configurePhase = ''
    mkdir -p Build/Resources/ThirdParty
    cp ${bootstrap-file} Build/Resources/ThirdParty/bootstrap-5.3.3.zip

    cd ./Build
    cmake .. $cmakeFlags
  '';

   buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ls
    cp ./OrthancDicomWeb $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Plugin that extends Orthanc with support for the DICOMweb protocols";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      dvcorreia
    ];
    platforms = [
      "x86_64-linux"
    ];
  };
})
