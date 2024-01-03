{ config, pkgs, lib, inputs, outputs, ... }:

let
  lanIface = "enp4s0";
in
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
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ "kvm-amd" "nct6775" ];
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

  networking = {
    hostName = "b550";

    # Bridge for VMs
    bridges.br0.interfaces = [ lanIface ];
    interfaces.br0.useDHCP = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  systemd.services.wakeonlan = {
    description = "Re-enable Wake-On-LAN on every boot";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "true";
      ExecStart = "${pkgs.ethtool}/sbin/ethtool -s ${lanIface} wol g";
    };
    wantedBy = [ "default.target" ];
  };

  system.stateVersion = "23.05";

} // (import ./b550-disko.nix)
