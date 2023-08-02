{ config, lib, ... }:

let
  cfg = config.my.gaming.steam;
in
{
  options.my.gaming.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
