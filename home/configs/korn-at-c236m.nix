{ pkgs, lib, outputs, ... }:

{
  imports = [
    outputs.homeModules.default
    ./korn.nix
  ];

  my = {
    primaryDisplayResolution = { horizontal = 1680; vertical = 1050; };

    desktop.enable = true;
  };

  home.stateVersion = "23.05";
}
