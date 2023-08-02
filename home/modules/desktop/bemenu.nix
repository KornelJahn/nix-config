# Config of bemenu, dmenu replacement for Wayland

{ config, pkgs, lib, ... }:

let
  inherit (config.my.desktop.theme) termFont topBar;
  cfg = config.my.desktop.bemenu;
  font = "${termFont.name} ${termFont.style} ${toString topBar.fontSize}";
in
{
  options.my.desktop.bemenu.enable = lib.mkEnableOption "bemenu";

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.bemenu ];
      sessionVariables = {
        BEMENU_OPTS = with config.colorscheme.colors; ''
          --fn '${font}' \
          --prompt ▶ \
          --line-height ${toString topBar.height} \
          --scrollbar none \
          --tb #${base00} \
          --tf #${base05} \
          --fb #${base00} \
          --ff #${base05} \
          --nb #${base00} \
          --nf #${base05} \
          --hb #${base00} \
          --hf #${base0A} \
          --sb #${base00} \
          --sf #${base08} \
        '';
      };
    };
  }; # config
}
