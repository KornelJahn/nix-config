# ThinkPad X13 Gen 1 AMD

{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.disko.nixosModules.disko
    outputs.nixosModules.default
    ./korn.nix
  ];

  my = {
    desktop = {
      enable = true;
      brotherMfp.enable = true;
    };
    gaming = {
      devilutionx.enable = true;
      diablo2.enable = true;
    };
    network = {
      shares.enable = true;
      tailscale.enable = true;
    };
    virtualization.enable = true;
    zfs.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "ehci_pci"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [ "kvm-amd" "amdgpu" ];
    loader.systemd-boot.enable = true;
  };

  # neededForBoot flag is not settable from disko
  fileSystems = {
    "/var/log".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  swapDevices = [ ];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault
      config.hardware.enableRedistributableFirmware;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  networking.hostName = "griswold";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05";

} // (import ./griswold-disko.nix)
