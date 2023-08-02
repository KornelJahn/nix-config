{ config, lib, ... }:

{
  home.sessionVariables = {
    # TODO: check if needed
    # TMUX_TMPDIR = "";
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "xterm-256color";
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
