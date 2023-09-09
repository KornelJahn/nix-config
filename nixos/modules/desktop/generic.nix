{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.generic;
in
{
  options.my.desktop.generic = {
    enable = lib.mkEnableOption "generic system-level desktop settings";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        polkit_gnome # for a Policy Kit authentication agent
      ];

      # Make applications find files in <prefix>/share
      pathsToLink = [ "/share" "/libexec" ];

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

    fonts.enableDefaultFonts = lib.mkDefault true;

    hardware = {
      bluetooth = {
        enable = true;
        package = pkgs.bluezFull;
        # WORKAROUND: fix bluetooth SAP (SIM Access Profile) related errors
        disabledPlugins = [ "sap" ];
      };

      sane = {
        enable = true;
        brscan4 = {
          enable = true;
          netDevices = {
            home = {
              model = "DCP-L2560DW";
              nodename = "mfprinter.home.arpa";
            };
          };
        };
      };
    };

    security.rtkit.enable = true;

    services = {
      # Brother DCP-L2560DW printer CUPS setup:
      # Protocol: IPP
      # URI: ipp://mfprinter.home.arpa:631/ipp/print
      # Make: Generic
      # Model: IPP Everywhere
      printing.enable = true;

      # TODO: replace by ssh-agent?
      # gnome.gnome-keyring.enable = true;

      upower.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    sound.enable = true;
  };
}
