{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.disko.nixosModules.disko
    outputs.nixosModules.default
    ./korn.nix
  ];

  my = {
    desktop.enable = true;
    gaming.devilutionx.enable = true;
    network = {
      shares.enable = false;
      tailscale.enable = true;
    };
    zfs.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader.systemd-boot.enable = true;
  };

  # neededForBoot flag is not settable from disko
  fileSystems = {
    "/var/log".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  hardware = {
    opengl.enable = true;
  };

  networking.hostName = "rpi4";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  system.stateVersion = "23.05";

} // (import ./rpi4-disko.nix)
