{ pkgs, ... }:

{
  importGsettings = pkgs.writeShellApplication {
    name = "my-import-gsettings";
    text = builtins.readFile ./bin/my-import-gsettings;
    runtimeInputs = with pkgs; [ glib ];
  };

  swayScreenshot = pkgs.writeShellApplication {
    name = "my-sway-screenshot";
    text = builtins.readFile ./bin/my-sway-screenshot;
    runtimeInputs = with pkgs; [ grim jq sway sway-contrib.grimshot ];
  };

  # volume = pkgs.writeShellApplication {
  #   name = "my-volume";
  #   text = builtins.readFile ./bin/my-volume;
  #   runtimeInputs = with pkgs; [ pamixer ];
  # };

  colorPicker = pkgs.writeShellApplication {
    name = "my-color-picker";
    text = builtins.readFile ./bin/my-color-picker;
    runtimeInputs = with pkgs; [ grim imagemagick slurp ];
  };

  swayWindows = pkgs.writeShellApplication {
    name = "my-sway-windows";
    text = builtins.readFile ./bin/my-sway-windows;
    runtimeInputs = with pkgs; [ jq sway ];
  };
}
