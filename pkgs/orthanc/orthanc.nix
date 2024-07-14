{
  lib,
  stdenv,
  fetchhg,
  xcode,
  gnumake
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "orthanc";
  version = "1.12.4";

  src = fetchhg {
    url = "https://orthanc.uclouvain.be/hg/orthanc/";
    rev = "023787ecaff2";
    sha256 = "16mgii4iki1024sd5fih2s9dwmxfxfivzqdawbwgl2s8pfgisgxf";
  };

  buildInputs = [
    xcode
    gnumake
  ];

  meta = {
    description = "Orthanc is a lightweight DICOM server for medical imaging";
    homepage = "https://www.orthanc-server.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      jodogne
      "Alain Mazy"
    ];
    platforms = [
      "aarch64-darwin"
    ];
  };
})
