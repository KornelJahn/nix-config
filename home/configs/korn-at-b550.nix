{ pkgs, lib, outputs, ... }:

{
  imports = [
    outputs.homeModules.default
    ./korn.nix
  ];

  my = {
    desktop.enable = true;
    gaming.devilutionx.enable = true;
  };

  home.stateVersion = "23.05";
}
