{ config, lib, ... }:

let
  cfg = config.my.gaming.devilutionx;
in
{
  options.my.gaming.devilutionx = {
    enable = lib.mkEnableOption "devilutionX firewall settings";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 6112 ];
    };
  };
}
