{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.swaylock;
in
{
  options.my.desktop.swaylock = {
    enable = lib.mkEnableOption "system-level swaylock config";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.swaylock = { };
  };
}
