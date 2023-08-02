{ config, lib, ... }:

{
  # Keep $HOME reasonably clean
  #
  # Move miscellaneous dot-files and dot-directories not obeying the XDG Base
  # Directory Specification to the respective XDG directories.

  home = {
    sessionVariables = {
      IPYTHONDIR = "${config.xdg.configHome}/ipython";
      LESSHISTFILE = "";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      PYTHONSTARTUP = "${config.xdg.configHome}/pythonrc";
      # GNUPGHOME = "${config.xdg.dataHome}/gnupg";
      # LESSKEY = "${config.xdg.configHome}/less/keys";
      # WGETRC = "${config.xdg.configHome}/wget/wgetrc";
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "pythonrc".source = ./config/pythonrc;
      "npm/npmrc".source = ./config/npm/npmrc;
    };

    userDirs = {
      enable = true;
      createDirectories = true;

      # Point disabled directories to the home dir
      # https://freedesktop.org/wiki/Software/xdg-user-dirs/
      publicShare = "${config.home.homeDirectory}"; # disabled
      templates = "${config.home.homeDirectory}"; # disabled
    };
  };
}
