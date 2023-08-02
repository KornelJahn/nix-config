{ pkgs, config, lib, ... }:

let
  cfg = config.my.network.tailscale;
in
{
  options.my.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence."/persist" = {
      directories = [
        { directory = "/var/lib/tailscale"; mode = "u=rwx,g=,o="; }
      ];
    };

    networking = {
      # Use Tailscale MagicDNS
      networkmanager.insertNameservers = [ "100.100.100.100" ];

      firewall = {
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };
    };

    services.tailscale = {
      enable = true;
      package = pkgs.tailscale;
    };
  };
}
