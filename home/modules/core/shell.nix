{ config, lib, ... }:

{
  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.cacheHome}/bash/history";
    shellAliases = {
      l = "ls -lah --group-directories-first";
      # Make ipython follow terminal colors
      ipython = "ipython --colors=Linux";
    };
    profileExtra = ''
      mkdir -p $XDG_CACHE_HOME/bash
    '';
    bashrcExtra = ''
      export CONFIG_REPODIR="$HOME/Repos/nix-config"

      alias nr='sudo nixos-rebuild --flake "$CONFIG_REPODIR" '
      alias hm='home-manager --flake "$CONFIG_REPODIR" '

      if [[ "$TERM" != "linux" || -z "$DISPLAY" ]]; then
        # Aliases to apply settings (e.g. color schemes) only in terminal
        # emulators but not in tty
        # alias mc='MC_SKIN=default mc'
        alias mc='MC_SKIN=julia256 mc'
        # Alias to force black & white mode
        # alias mc='mc -b'
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.readline = {
    enable = true;
    includeSystemConfig = true;
    variables.completion-ignore-case = "on";
  };

  # Customize prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      command_timeout = 1000;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
        vicmd_symbol = "[>](bold blue)";
      };
      directory = {
        truncation_length = 255;
        truncate_to_repo = false;
        style = "bold blue";
      };
      git_branch = {
        always_show_remote = true;
      };
      hostname = {
        ssh_only = false;
        style = "bold green";
        format = "[$hostname]($style):";
      };
      username = {
        show_always = true;
        format = "[$user]($style)@";
      };

      battery.disabled = true;
      cmd_duration.disabled = true;
      conda.disabled = true;
      env_var.disabled = true;
      julia.disabled = true;
      memory_usage.disabled = true;
      package.disabled = true;
      python.disabled = true;
      ruby.disabled = true;
      shlvl.disabled = true;
      time.disabled = true;
    };
  };
}

