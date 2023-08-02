{ config, pkgs, diskoPkgs, inputs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  name = "installer-shell";
  buildInputs = [
    diskoPkgs.disko
    pkgs.coreutils
    pkgs.jq
    pkgs.mkpasswd
    pkgs.util-linux
    pkgs.zfs
  ];
  shellHook = ''
    export PATH="${builtins.toString ./.}:$PATH"
  '';

  # Environment variables
  NIX_CONFIG = "experimental-features = nix-command flakes";
  INST_TARGET_HOST = config.networking.hostName;
  INST_FLAKE_DIR = builtins.toString inputs.self.outPath;
}
