{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.diablo2;
in
{
  options.my.gaming.diablo2 = {
    enable = lib.mkEnableOption "Diablo 2: LoD using Wine";
  };

  config = lib.mkIf cfg.enable {
    my.gaming.wine.enable = true;

    programs.java = {
      enable = true; # Required by GoMule
      package = lib.mkDefault pkgs.jre;
    };
  };
}
