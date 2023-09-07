{ config, lib, ... }:

let
  cfg = config.my.desktop;
in
{
  imports = [
    ./bemenu.nix
    ./foot.nix
    ./generic.nix
    ./theme.nix
    ./i3status-rust.nix
    ./imv.nix
    ./mako.nix
    ./mpv.nix
    ./swaylock.nix
    ./swaywm.nix
  ];

  options.my.desktop = with lib; {
    enable = mkEnableOption "Sway desktop";
  };

  config.my.desktop = lib.mkIf cfg.enable {
    # Required modules
    bemenu.enable = lib.mkForce true;
    foot.enable = lib.mkForce true;
    generic.enable = lib.mkForce true;
    theme.enable = lib.mkForce true;
    i3statusRust.enable = lib.mkForce true;
    mako.enable = lib.mkForce true;
    swaylock.enable = lib.mkForce true;
    swaywm.enable = lib.mkForce true;
    # Optional modules (opt-out)
    imv.enable = lib.mkDefault true;
    mpv.enable = lib.mkDefault true;
  };
}
