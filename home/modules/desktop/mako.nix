# Config of mako, a Wayland-native notification daemon

{ config, lib, ... }:

let
  inherit (config.my.desktop.theme) termFont topBar;
  cfg = config.my.desktop.mako;
  font = "${termFont.name} ${termFont.style} ${toString topBar.fontSize}";
in
{
  options.my.desktop.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {
    services.mako = with config.colorscheme.colors; {
      enable = true;
      inherit font;
      borderSize = 2;
      backgroundColor = "#${base00}ff";
      textColor = "#${base05}ff";
      borderColor = "#${base05}ff";
      icons = false;
      extraConfig = ''
        [urgency=high]
        text-color=#${base08}ff
        border-color=#${base08}ff
      '';
    };
  }; # config
}
