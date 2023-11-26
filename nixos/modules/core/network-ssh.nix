{ config, lib, ... }:

{
  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    firewall.enable = true;

    # Generate the hostId from the hostname
    hostId = builtins.substring 0 8 (
      builtins.hashString "sha256" config.networking.hostName
    );
  };

  services.fail2ban.enable = true;

  programs.ssh = {
    extraConfig = ''
      AddKeysToAgent yes
    '';
    startAgent = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = lib.mkForce false;
    };
    hostKeys = [
      {
        bits = 4096;
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
