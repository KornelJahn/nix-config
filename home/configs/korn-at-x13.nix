{ pkgs, lib, outputs, ... }:

{
  imports = [
    outputs.homeModules.default
    ./korn.nix
  ];

  my = {
    desktop.enable = true;
    gaming = {
      devilutionx.enable = true;
      diablo2.enable = true;
    };
  };

  home.stateVersion = "23.05";

  services.kanshi.profiles = {
    undocked = {
      outputs = [
        { criteria = "eDP-1"; }
      ];
    };
    docked = {
      outputs = [
        {
          criteria = "eDP-1";
          position = "1920,0";
        }
        {
          # Use make-model-serial criterion for external monitors as the name
          # (DP-?) may change when reconnected. Get it using:
          #     swaymsg -t get_outputs
          criteria = "Iiyama North America PL2493H 1211424213213";
          position = "0,0";
        }
      ];
    };
  };
}
