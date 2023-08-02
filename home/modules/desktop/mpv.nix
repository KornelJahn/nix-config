# Config of mpv, a command-line media player

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.mpv;
in
{
  options.my.desktop.mpv.enable = lib.mkEnableOption "mpv";

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        gpu-context = "wayland";
      };
    };
  }; # config
}
