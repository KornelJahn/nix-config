# Config of foot, a Wayland-native terminal emulator

{ config, pkgs, lib, ... }:

let
  inherit (config.my.desktop.theme) termFont;
  cfg = config.my.desktop.foot;
  font = "${termFont.name} ${termFont.style}:size=${toString termFont.size}";
in
{
  options.my.desktop.foot.enable = lib.mkEnableOption "foot terminal emulator";

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          inherit font;
          dpi-aware = "no";
        };
        scrollback = {
          lines = 1000;
        };
        colors = with config.colorscheme.colors; {
          background = base00;
          foreground = base05;

          # Normal colors
          regular0 = base00; # Black
          regular1 = base08; # Red
          regular2 = base0B; # Green
          regular3 = base0A; # Yellow
          regular4 = base0D; # Blue
          regular5 = base0E; # Magenta
          regular6 = base0C; # Cyan
          regular7 = base05; # White

          # Bright colors
          bright0 = base03; # Black
          bright1 = base08; # Red
          bright2 = base0B; # Green
          bright3 = base0A; # Yellow
          bright4 = base0D; # Blue
          bright5 = base0E; # Magenta
          bright6 = base0C; # Cyan
          bright7 = base07; # White
        }; # colors
      }; # settings
    }; # programs.foot
  }; # config
}
