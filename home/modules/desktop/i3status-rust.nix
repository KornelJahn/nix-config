# Config of i3status-rust, a status bar generator for Sway bar

{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop.i3statusRust;
in
{
  options.my.desktop.i3statusRust.enable = lib.mkEnableOption "i3status-rust";

  config = lib.mkIf cfg.enable {
    # WORKAROUND
    xdg.configFile."i3status-rust/config.toml".source =
     config.lib.file.mkOutOfStoreSymlink
       "${config.xdg.configHome}/i3status-rust/config-default.toml";

    programs.i3status-rust = with config.colorscheme.colors; {
      enable = true;
      bars.default = {
        icons = "material-nf";
        settings = {
          theme = {
            theme = "plain";
            overrides = {
              separator = " ";
              idle_bg = "#${base00}";
              idle_fg = "#${base05}";
              info_bg = "#${base00}";
              info_fg = "#${base05}";
              good_bg = "#${base00}";
              good_fg = "#${base05}";
              critical_bg = "#${base00}";
              critical_fg = "#${base08}";
              warning_bg = "#${base00}";
              warning_fg = "#${base0A}";
              separator_bg = "#${base00}";
              separator_fg = "#${base05}";
            }; # overrides
          }; # theme
        }; # settings
        blocks = [
          {
            block = "focused_window";
            format = " $title_str(max_w:60) |";
            theme_overrides = {
              idle_fg = "#${base03}";
            };
          }
          {
            block = "temperature";
            format = " $icon $max{}C ";
            scale = "celsius";
            interval = 4;
            good = 20;
            idle = 50;
            info = 70;
            warning = 90;
            inputs = ["Package id 0" "SMBUSMASTER 0" "Tctl"];
          }
          {
            block = "net";
            format = " $icon {$ssid |}{$signal_strength |}";
            theme_overrides = {
              warning_fg = "#${base05}";
              critical_fg = "#${base05}";
            };
          }
          {
            block = "battery";
            driver = "sysfs";
            format = " $icon $percentage {$time |}";
            missing_format = "";
            interval = 10;
          }
          {
            block = "backlight";
            missing_format = "";
            minimum = 10;
            step_width = 10;
            root_scaling = 2.4065401804339555;
          }
          {
            block = "sound";
            click = [
              {
                button = "left";
                cmd = "pavucontrol";
              }
            ];
          }
          {
            block = "keyboard_layout";
            driver = "sway";
            format = " ^icon_keyboard $layout ";
            mappings = {
              "English (US)" = "US";
              "Hungarian (N/A)" = "HU";
            };
          }
          {
            block = "time";
            interval = 60;
            format = " $icon $timestamp.datetime(f:'%a %d/%m %R') ";
          }
        ]; # blocks
      }; # bars.default
    }; # programs.i3status-rust
  }; # config
}
