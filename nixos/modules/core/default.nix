{ ... }:

# TODO: test if root account is disabled
# TODO: test if getting a rescue shell as root is still possible by manually
# adding at boot
#
# rescue systemd.setenv=SYSTEMD_SULOGIN_FORCE=1
#
# to the boot-loader entry.

{
  imports = [
    ./console-locale.nix
    ./network-ssh.nix
    ./nix-nixpkgs.nix
    ./persistence.nix
    ./programs.nix
  ];

  users.mutableUsers = false;

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=20s
    DefaultTimeoutStopSec=10s
  '';
}
