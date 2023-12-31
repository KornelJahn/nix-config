{ inputs, config, lib, ... }:

let
  inherit (inputs) nix-colors;
in
{
  imports = [ nix-colors.homeManagerModule ];

  # To match the Mint-Y GTK theme, select a colorscheme with neutral grays
  colorscheme = nix-colors.colorSchemes.decaf;

  programs.dircolors.enable = true;

  home.sessionVariables = {
    NEWT_COLORS_FILE = "${config.xdg.configHome}/newt/colors";
  };

  xdg.configFile."newt/colors".source = ./config/newt/colors;
}
