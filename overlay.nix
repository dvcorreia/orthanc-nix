final: prev: {
  orthanc = final.callPackage ./orthanc.nix { };
  orthancPlugins = final.callPackage ./plugins { };
}
