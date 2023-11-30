{ config, lib, ... }:

let
  cfg = config.my.gaming.diablo2;
in
{
  options.my.gaming.diablo2 = {
    enable = lib.mkEnableOption "Diablo 2: LoD firewall settings";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 6112 4000 ];
    };
  };
}
