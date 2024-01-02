{ pkgs, lib, outputs, ... }:

{
  imports = [
    outputs.homeModules.default
    ./korn.nix
  ];

  my = {
    desktop.enable = true;
    gaming = {
      devilutionx.enable = false;
    };
  };

  home.stateVersion = "23.11";
}
