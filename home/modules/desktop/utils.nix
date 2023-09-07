{ pkgs, ... }:

{
  my-brightness = pkgs.writeShellApplication {
    name = "my-brightness";
    text = builtins.readFile ./bin/my-brightness;
    runtimeInputs = [ pkgs.brightnessctl pkgs.gawk ];
  };

  my-volume = pkgs.writeShellApplication {
    name = "my-volume";
    text = builtins.readFile ./bin/my-volume;
    runtimeInputs = [ pkgs.pamixer ];
  };
}
