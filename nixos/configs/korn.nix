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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlFAVz0HuwMRm/I8NO0XlKOh0ridZ7NuNJ6IeyRTZ5 korn@c236m"
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
