{ config, lib, ... }:

{
  imports = [
    ./core
    ./desktop
    # ./devel
    ./gaming
  ];

  options.my = {
    primaryDisplayResolution = {
      horizontal = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = ''
          Horizontal resolution of the primary display. Used for wallpaper
          generation, scaling of UI elements and fonts.
        '';
      };
      vertical = lib.mkOption {
        type = lib.types.int;
        default = 1080;
        description = ''
          Vertical resolution of the primary display. Used for wallpaper
          generation, scaling of UI elements and fonts.
        '';
      };
    };

    hwBrightnessControl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        True if brightness control keys control brightness through hardware.
      '';
    };
  };
}
