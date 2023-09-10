# Window manager-agnostic settings for Wayland

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.generic;
in
{
  options.my.desktop.generic = {
    enable = lib.mkEnableOption "generic Wayland desktop settings";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Essential apps
      firefox-wayland # Wayland-native Mozilla Firefox
      pavucontrol # volume control GUI
      xorg.xeyes # to check whether an app is using Xwayland :)

      # Additional apps
      ffmpeg-full # to record and convert audio and video
      v4l-utils # Video 4 Linux 2 utils to record from video sources
      gimp # raster graphics editor
      gnome.simple-scan # scanning utility
      inkscape # vector-graphics editor
      libnotify # to manually send notifications
      libreoffice # office suite
      pcmanfm # GUI file manager
      remmina # remote desktop app
      waypipe # remote connection utility to Wayland desktop
      zathura # lightweight document viewer with vi-like keybindings
    ] ++ (builtins.attrValues (import ./utils.nix { inherit pkgs; }));

    home.sessionVariables = {
      # Wayland-specific session variables
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      BEMENU_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };

    programs.bash.shellAliases = {
      # FIXME: workaround for lxappearance, it crashes on Sway if the default
      # value of GDK_BACKEND is "wayland".
      lxappearance = "GDK_BACKEND=x11 lxappearance";
    };
  }; # config
}
