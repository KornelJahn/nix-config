{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.brotherMfp;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.my.desktop.brotherMfp = {
    enable = lib.mkEnableOption "printing and scanning with Brother MFP";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      persistence."/persist" = {
        directories = [
          { directory = "/var/lib/cups"; mode = "u=rwx,g=rx,o=rx"; }
          {
            directory = "/var/cache/cups";
            group = "lp";
            mode = "u=rwx,g=rwx,o=";
          }
        ];
      };
    };

    fonts.enableDefaultPackages = lib.mkDefault true;

    hardware.sane = {
      enable = true;
      brscan4 = lib.mkIf (system == "x86_64-linux") {
        enable = true;
        netDevices = {
          home = {
            model = "DCP-L2560DW";
            nodename = "mfp.home.arpa";
          };
        };
      };
    };

    # Brother DCP-L2560DW printer CUPS setup:
    # Protocol: IPP
    # URI: ipp://mfp.home.arpa:631/ipp/print
    # Make: Generic
    # Model: IPP Everywhere
    services.printing.enable = true;
  };
}
