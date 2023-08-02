# Helper function to filter disks and/or zpools from a disko config for partial
# partitioning and formatting

{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, disks ? null
, zpools ? null
, wrappedDiskoFile
, ...
}:

let
  diskoConfig = import wrappedDiskoFile;
in
{
  disko.devices = {
    disk = lib.filterAttrs
      (n: v: disks == null || builtins.elem n disks)
      diskoConfig.disko.devices.disk;

    zpool = lib.filterAttrs
      (n: v: zpools == null || builtins.elem n zpools)
      diskoConfig.disko.devices.zpool;
  };
}
