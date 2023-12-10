{ config, lib, pkgs, ... }:

let
  inherit (config.my.desktop.theme)
    cursorTheme
    termFont
    topBar
    wallpaper
    ;

  cfg = config.my.desktop.swaywm;

  hwBrCtl = config.my.hwBrightnessControl;

  # Python enviromnent for Sway
  swayPythonEnv = pkgs.python3.withPackages (
    ps: with pkgs; with ps; [
      i3ipc
      ipython
      msgpack
    ]
  );

  # Utilities and scripts
  xargs = "${pkgs.findutils}/bin/xargs";
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";
  locker = "${pkgs.swaylock}/bin/swaylock -f";

  scripts = import ./swaywm/scripts.nix { inherit lib pkgs; };
  utils = import ./utils.nix { inherit pkgs; };

  execCmd = cmd: op: "exec ${cmd} ${op}";
  execCmdToWob = cmd: op: "exec ${cmd} ${op} > $SWAYSOCK.wob";

  myScreenshot = execCmd "${scripts.swayScreenshot}/bin/my-sway-screenshot";
  myVolume = execCmd "${utils.my-volume}/bin/my-volume";
  myBrightness = execCmd "${utils.my-brightness}/bin/my-brightness";

  # Modifiers
  mod = "Mod4";
  altMod = "Mod1";

  bindingModes = import ./swaywm/modes.nix { inherit config pkgs lib mod; };

  # WORKAROUND:
  # https://github.com/nix-community/home-manager/issues/2659
  homeSessionVariables = ''
    . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
  '';
in
{
  options.my.desktop.swaywm = with lib; {
    enable = mkEnableOption "Sway window manager";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = false;
      wrapperFeatures.gtk = true;
      xwayland = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        # https://github.com/swaywm/sway/issues/595
        export _JAVA_AWT_WM_NONREPARENTING=1
        export DESKTOP_SESSION=gnome
        # eval $(/run/wrappers/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh --daemonize 2>/dev/null)
        export SSH_AUTH_SOCK
      '' + homeSessionVariables;
      config = rec {
        fonts = {
          names = [ termFont.name ];
          style = termFont.style;
          size = topBar.fontSize + 0.0; # Convert to float
        };

        menu = "${pkgs.bemenu}/bin/bemenu-run | ${xargs} ${swaymsg} exec --";

        terminal = "${pkgs.foot}/bin/footclient";

        bars = [
          {
            inherit fonts;
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
            trayOutput = null;
            extraConfig = ''
              height ${toString topBar.height}
              status_padding 0
            '';
            colors = with config.colorscheme.colors; {
              separator = "#${base05}";
              background = "#${base00}";
              statusline = "#${base05}";
              focusedWorkspace = {
                border = "#${base0A}";
                background = "#${base0A}";
                text = "#${base00}";
              };
              activeWorkspace = {
                border = "#${base05}";
                background = "#${base05}";
                text = "#${base00}";
              };
              inactiveWorkspace = {
                border = "#${base00}";
                background = "#${base00}";
                text = "#${base05}";
              };
              urgentWorkspace = {
                border = "#${base08}";
                background = "#${base08}";
                text = "#${base00}";
              };
              bindingMode = {
                border = "#${base07}";
                background = "#${base07}";
                text = "#${base00}";
              };
            };
          }
        ]; # bars

        colors = with config.colorscheme.colors; {
          background = "#${base0A}";
          focused = {
            border = "#${base0A}";
            background = "#${base0A}";
            text = "#${base00}";
            indicator = "#${base0A}";
            childBorder = "#${base0A}";
          };
          focusedInactive = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          placeholder = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          unfocused = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          urgent = {
            border = "#${base08}";
            background = "#${base08}";
            text = "#${base00}";
            indicator = "#${base08}";
            childBorder = "#${base08}";
          };
        }; # colors

        focus.followMouse = false;

        floating = {
          border = 1;
          criteria = [
            { title = "Password Required - Mozilla Firefox"; }
            { app_id = "pavucontrol"; }
            { class = "XEyes"; }
            { class = "Lxappearance"; }
            { app_id = "foot-floating"; }
          ];
          titlebar = false;
        }; # floating

        input = {
          "*" = {
            xkb_layout = "us,hu";
            xkb_options = "ctrl:nocaps,grp:alt_shift_toggle";
          };
        }; # input

        modifier = mod;
        left = "h";
        down = "j";
        up = "k";
        right = "l";

        keybindings = lib.mkOptionDefault (
          {
            # Move workspaces between monitors
            "${mod}+${altMod}+${left}" = "move workspace to output left";
            "${mod}+${altMod}+${down}" = "move workspace to output down";
            "${mod}+${altMod}+${up}" = "move workspace to output up";
            "${mod}+${altMod}+${right}" = "move workspace to output right";
            "${mod}+${altMod}+Left" = "move workspace to output left";
            "${mod}+${altMod}+Down" = "move workspace to output down";
            "${mod}+${altMod}+Up" = "move workspace to output up";
            "${mod}+${altMod}+Right" = "move workspace to output right";

            # Audio and brightness controls
            # WORKAROUND: include --locked in a hacky way to enable these
            # bindings even if the screen is locked.
            "--locked XF86AudioRaiseVolume" = myVolume "raise";
            "--locked XF86AudioLowerVolume" = myVolume "lower";
            "--locked XF86AudioMute" = myVolume "toggle-mute";
            "--locked XF86AudioMicMute" = myVolume "toggle-mute-mic";
            "--locked XF86MonBrightnessUp" =
              if hwBrCtl then myBrightness "get" else myBrightness "raise";
            "--locked XF86MonBrightnessDown" =
              if hwBrCtl then myBrightness "get" else myBrightness "lower";

            # Screenshot
            "${mod}+Print" = myScreenshot "screen";
            "${mod}+Shift+Print" = myScreenshot "focused";
            "${mod}+Shift+s" = myScreenshot "copy-area";
          } // bindingModes.keybindings
        ); # keybindings

        # Binding modes
        modes = lib.mkOptionDefault bindingModes.modes;

        output = {
          "*" = with config.colorscheme.colors; {
            bg = "${wallpaper.path} ${wallpaper.scaling} #${base00}";
          };
        }; # output

        seat = {
          "*" = {
            "xcursor_theme" = "${cursorTheme.name} ${toString cursorTheme.size}";
          };
        }; # seat

        startup = [
          # This ensures all user units started after the command (not those
          # already running) set the variables
          # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
          {
            command =
              let
                dbusCmd = "${pkgs.dbus}/bin/dbus-update-activation-environment";
                vars = [ "DISPLAY" "WAYLAND_DISPLAY" "SWAYSOCK" ];
                varsStr = lib.concatStringsSep " " vars;
              in
              ''
                systemctl --user import-environment ${varsStr} && \
                hash ${dbusCmd} 2>/dev/null && ${dbusCmd} --systemd ${varsStr}
              '';
          }
          {
            command = ''
              ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
            '';
          }
          {
            command = "${scripts.importGsettings}/bin/my-import-gsettings";
            always = true;
          }
          {
            command = "${pkgs.autotiling}/bin/autotiling";
          }
          {
            command = "${pkgs.kanshi}/bin/kanshi";
            always = true;
          }
          {
            command = with config.colorscheme.colors; ''
              ${pkgs.coreutils}/bin/mkfifo $SWAYSOCK.wob && \
              ${pkgs.coreutils}/bin/tail -f $SWAYSOCK.wob \
              | ${pkgs.wob}/bin/wob \
                --border-color '#${base05}ff' \
                --background-color '#${base00}ff' \
                --bar-color '#${base0A}ff'
            '';
          }
          {
            command = "${pkgs.foot}/bin/foot --server";
          }
        ];

        assigns = {
          "9" = [{ app_id = "firefox"; }];
        };

        window = {
          border = 1;
          commands = [
            {
              command = "resize set 1600px 800px";
              criteria = { app_id = "pavucontrol"; };
            }
            {
              command = "move position center";
              criteria = { floating = true; };
            }
            {
              command = "move to workspace 8";
              criteria = {
                app_id = "firefox";
                title = "^Mozilla Firefox Private Browsing$";
              };
            }
          ];
          hideEdgeBorders = "smart";
          titlebar = false;
        };

        workspaceAutoBackAndForth = true;
      }; # config

      extraConfig = ''
        floating_maximum_size 1900 x 1000
      '';
    }; # wayland.windowManager.sway

    services.kanshi.enable = true;

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 180;
          command = ''${swaymsg} "output * dpms off"'';
          resumeCommand = ''${swaymsg} "output * dpms on"'';
        }
      ];
      events = [
        { event = "before-sleep"; command = locker; }
      ];
    };

    home.packages = with pkgs; [
      wl-clipboard # Wayland copy & paste command-line utilities
      swayPythonEnv
    ] ++ (builtins.attrValues scripts);
  }; # config
}
