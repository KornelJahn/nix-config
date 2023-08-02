{ config, pkgs, lib, ... }:

let
  cfg = config.my.virtualization;
in
{
  options.my.virtualization = {
    enable = lib.mkEnableOption "virtualization";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = [ pkgs.virt-manager ];
  };
}
