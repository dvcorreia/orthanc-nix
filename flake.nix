{
  description = "Orthanc derivations for NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-linux"
        "aarch64-darwin" # let's try, fingers crossed
        "x86_64-darwin" # let's try, fingers crossed
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );
    in
    {
      overlay = import ./overlay.nix;

      packages = forAllSystems (system: {
        default = (nixpkgsFor.${system}).orthanc;
        orthanc = (nixpkgsFor.${system}).orthanc;
      });

      formatter = forAllSystems (system: (nixpkgsFor.${system}).nixfmt-rfc-style);
    };
}
