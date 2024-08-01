let
  pkgs = import <nixpkgs> {};
in
{
  orthanc = pkgs.callPackage ./orthanc.nix { };
}
