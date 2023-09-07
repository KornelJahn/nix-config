# Desktop theme settings

{ inputs, config, pkgs, lib, ... }:

let
  inherit (inputs) self nix-colors;

  nix-colors-lib = nix-colors.lib-contrib { inherit pkgs; };

  cfg = config.my.desktop.theme;

  hRes = config.my.primaryDisplayResolution.horizontal;
  vRes = config.my.primaryDisplayResolution.vertical;

  getGtkPkg = mod:
    let
      pkg = (builtins.getAttr mod config.gtk).package;
    in
    lib.optional (pkg != null) pkg;
in
{
  options.my.desktop.theme = {
    enable = lib.mkEnableOption "custom desktop theme";

    wallpaper = {
      path = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to the wallpaper.
        '';
        default = self.lib.mkWallpaper {
          inherit pkgs;
          svgTemplate = ./random-hex-grid-dark-wallpaper.svg.template;
          inherit (config) colorscheme;
          width = config.my.primaryDisplayResolution.horizontal;
        };
      };

      scaling = lib.mkOption {
        type = lib.types.enum [ "stretch" "fit" "fill" "center" "tile" ];
        default = "tile";
      };
    }; # wallpaper

    termFont = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Iosevka Term Nerd Font";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerdfonts;
      };

      style = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Regular";
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = if hRes >= 1920 then 16 else 12;
      };
    }; # termFont

    topBar = {
      fontSize = lib.mkOption {
        type = lib.types.ints.positive;
        default = cfg.termFont.size;
      };

      height = lib.mkOption {
        type = lib.types.ints.positive;
        default = cfg.topBar.fontSize + 9;
      };
    }; # topBar

    cursorTheme = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Vanilla-DMZ";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.vanilla-dmz;
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 24;
      };
    };
  }; # options.my.desktop.theme

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        corefonts # MS TrueType core fonts

        cfg.termFont.package

        # gsettings-desktop-schemas

        # Needed for proper GTK and QT5 theming
        gtk-engine-murrine
        gnome3.gnome-themes-extra
        libsForQt5.qtstyleplugins
      ];

      sessionVariables = {
        # Add all theme directories to XDG_DATA_DIRS
        XDG_DATA_DIRS = (
          (
            builtins.foldl' (s: p: s + "${p.out}/share:") "" (
              (getGtkPkg "theme")
              ++ (getGtkPkg "iconTheme")
              ++ (getGtkPkg "cursorTheme")
            )
          ) + "$XDG_DATA_DIRS"
        );
        # SVG loader for pixbuf (needed for GTK svg icon themes)
        GDK_PIXBUF_MODULE_FILE =
          "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache";
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
        # QT_FONT_DPI = 128;
      }; # sessionVariables
    }; # home

    gtk = {
      enable = true;
      theme = {
        # TODO:
        # Mint-Y theme seems more polished than the auto-generated one.
        # name = config.colorscheme.slug;
        # package = nix-colors-lib.gtkThemeFromScheme {
        #   scheme = config.colorscheme;
        # };
        name = "Mint-Y-Dark-Grey";
        package = pkgs.cinnamon.mint-themes;
      };
      font = {
        name = "DejaVu Sans";
        package = pkgs.dejavu_fonts;
        size = cfg.termFont.size - 2;
      };
      iconTheme = {
        name = "Mint-Y-Dark-Grey";
        package = pkgs.cinnamon.mint-y-icons;
      };
      inherit (cfg) cursorTheme;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.bookmarks = [ ];
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    fonts.fontconfig.enable = true;
  }; # config
}
