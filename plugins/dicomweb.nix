{
  lib,
  pkgs,
  stdenv,
  fetchhg,
  orthanc,
}:

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
  ];

  buildInputs = with pkgs; [
    orthanc
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DALLOW_DOWNLOADS=OFF"
    "-DSTATIC_BUILD=OFF"
  ];

  configurePhase = ''
    mkdir Build
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
