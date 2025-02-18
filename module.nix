{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.orthanc;
in
{
  options.services.orthanc = {
    enable = mkEnableOption (mdDoc "Whether to enable Orthanc");

    package = mkOption {
      type = types.package;
      default = pkgs.orthanc;
      defaultText = literalExpression "pkgs.orthanc";
      description = mdDoc "Orthanc package to use.";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = mdDoc ''
        List of Orthanc plugins to enable. Each plugin should be a package
        containing the plugin's shared library (.so file).
      '';
      example = literalExpression ''
        with pkgs.orthancPlugins; [
          dicomweb
          webviewer
        ]
      '';
    };

    settings = mkOption {
      type = format.type;
      default = { };
      description = mdDoc ''
        Orthanc configuration. Refer to the Orthanc documentation for available options.
        The configuration will be written to a JSON file.
      '';
      example = literalExpression ''
        {
          Name = "MyOrthanc";
          StorageDirectory = "/var/lib/orthanc/db";
          IndexDirectory = "/var/lib/orthanc/index";
          DicomPort = 4242;
          HttpPort = 8042;
        }
      '';
    };

    user = mkOption {
      type = types.str;
      default = "orthanc";
      description = mdDoc "User account under which Orthanc runs.";
    };

    group = mkOption {
      type = types.str;
      default = "orthanc";
      description = mdDoc "Group account under which Orthanc runs.";
    };
  };

  config = mkIf cfg.enable {
    services.orthanc.settings = mkMerge [
      {
        Plugins = mkIf (cfg.plugins != [ ]) (map (p: "${p}/lib/*.so") cfg.plugins);
      }
      cfg.settings
    ];

    systemd.services.orthanc = {
      description = "Orthanc Dicom server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "30s";
        ExecStart = "${cfg.package}/bin/Orthanc ${format.generate "orthanc.json" cfg.settings}";
        User = "etcd";
      };
    };

    networking.firewall.allowedTCPPorts = mkMerge [
      (mkIf (cfg.settings.HttpPort != null) [ cfg.settings.HttpPort ])
      (mkIf (cfg.settings.DicomPort != null) [ cfg.settings.DicomPort ])
    ];

    environment.systemPackages = [ cfg.package ];
  };
}
