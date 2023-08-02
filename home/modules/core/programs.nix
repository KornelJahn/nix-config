{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bluetuith # Bluetooth TUI
    neofetch # System info script
    unzip # Extraction utility for zip files
  ];
}
