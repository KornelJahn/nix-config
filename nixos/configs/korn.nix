{ config, pkgs, inputs, ... }:

let
  inherit (inputs) self;
in
{
  users.users.korn = {
    isNormalUser = true;
    uid = 1000;
    passwordFile = "/persist/secrets/korn-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHG9IfhgH2JsPImpEcG0k1rXDgBsiWtCSvsY2udJUH89 korn@c236m"
    ];
    shell = pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
    ] ++ self.lib.filterExistingGroups config [
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
    ];
  };
}
