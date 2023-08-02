{ config, lib, ... }:

let
  cfg = config.my.gaming.torchlight2;
in
{
  options.my.gaming.torchlight2 = {
    enable = lib.mkEnableOption "Torchlight II";
  };

  config = lib.mkIf cfg.enable {
    my.gaming.steam.enable = lib.mkForce true;

    networking.firewall = {
      allowedTCPPorts = [ 4549 ];
      allowedUDPPorts = [ 4549 ];
      # NOTE: UDPORT :4171 needs to be set in
      # '~/.local/share/Runic Games/Torchlight 2/local_settings.txt'
      allowedUDPPortRanges = [{ from = 4171; to = 4179; }];
    };
  };
}
