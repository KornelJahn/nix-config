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
    gaming.devilutionx.enable = false;
    network = {
      shares.enable = false;
      tailscale.enable = true;
    };
    zfs.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [
      "pcie_brcmstb"
      "reset-raspberrypi"
      "usb_storage"
      "usbhid"
      "vc4"
      "xhci_pci"
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
    deviceTree.filter = "bcm2711-rpi-*.dtb";
  };

  networking.hostName = "rpi4";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  system.stateVersion = "23.11";

} // (import ./rpi4-disko.nix)
