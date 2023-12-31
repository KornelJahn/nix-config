{ config, pkgs, inputs, ... }:

let
  inherit (inputs) self;
in
{
  users.users.korn = {
    isNormalUser = true;
    uid = 1000;
    hashedPasswordFile = "/persist/secrets/korn-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSo3kOzjC1HX5aHNeseBxzK/ksD7KQvjDqohzl6Xppx korn@b550"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlFAVz0HuwMRm/I8NO0XlKOh0ridZ7NuNJ6IeyRTZ5 korn@c236m"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPirW5/3HS07wDu3BrEAtyCVABBSwQB6gDYr7dnsVajw korn@x13"
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
