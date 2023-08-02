{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.swaywm;
in
{
  options.my.desktop.swaywm = {
    enable = lib.mkEnableOption "system-level Sway config";
    greetd.enable = lib.mkEnableOption "greetd-based greeter";
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = lib.mkDefault true;

    environment.loginShellInit = lib.mkIf (!cfg.greetd.enable) ''
      if command -v sway > /dev/null &&
         [ -z $DISPLAY ] &&
         [ "$(tty)" = "/dev/tty1" ]
      then
        exec sway
      fi
    '';

    services.greetd = lib.mkIf cfg.greetd.enable {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        };
      };
    };
    # TODO: test these workarounds
    # WORKAROUND: fix tuigreet window not messed up with systemd output
    # https://github.com/apognu/tuigreet/issues/68#issuecomment-1192683029
    systemd.services.greetd.serviceConfig = lib.mkIf cfg.greetd.enable {
      ExecStartPre = "kill -SIGRTMIN+21 1";
      ExecStopPost = "kill -SIGRTMIN+20 1";
    };
    # Alternative:
    # https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
    # systemd.services.greetd.serviceConfig = lib.mkIf cfg.greetd.enable {
    #   Type = "idle";
    #   StandardInput = "tty";
    #   StandardOutput = "tty";
    #   StandardError = "journal"; # Without this errors will spam on screen
    #   # Without these bootlogs will spam on screen
    #   TTYReset = true;
    #   TTYVHangup = true;
    #   TTYVTDisallocate = true;
    # };
  };
}
