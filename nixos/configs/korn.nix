{ config, pkgs, inputs, ... }:

let
  inherit (inputs) self;
in
{
  users.users.korn = {
    isNormalUser = true;
    uid = 1000;
    passwordFile = "/persist/secrets/korn-password";
    openssh.authorizedKeys.keys = [ ];
    shell = pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "audio"
      "video"
    ] ++ self.lib.filterExistingGroups config [
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
    ];
  };
}
