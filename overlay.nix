final: prev: {
  orthanc = final.callPackage ./orthanc.nix { };
  orthanc-sdk = final.callPackage ./orthanc-sdk.nix { };
  orthancPlugins = final.callPackage ./plugins { };
}
