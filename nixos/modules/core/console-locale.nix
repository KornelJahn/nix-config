{ pkgs, ... }:

{
  time.timeZone = "Europe/Budapest";

  i18n = {
    # Substitute for the non-exisiting Paneuropean English locale
    defaultLocale = "en_IE.UTF-8";
    # Set ISO date & time with help of the Swedish locale
    extraLocaleSettings = { LC_TIME = "sv_SE.UTF-8"; };
  };

  console = {
    font = "ter-v22n";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };
}
