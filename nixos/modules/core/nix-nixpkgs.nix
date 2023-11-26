{ inputs, config, pkgs, lib, ... }:

{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };
    # TODO: update
    package = pkgs.nixVersions.nix_2_17;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      # FIXME: breaks Home Manager which still uses "nix-env" instead of "nix
      # profile"
      # https://github.com/nix-community/home-manager/issues/4593
      # use-xdg-base-directories = true;
      warn-dirty = false;
    };

    # Credits: Misterio77
    # https://raw.githubusercontent.com/Misterio77/nix-config/e227d8ac2234792138753a0153f3e00aec154c39/hosts/common/global/nix.nix

    # Add each flake input as a registry
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Map registries to channels (useful when using legacy commands)
    nixPath = lib.mapAttrsToList
      (name: value: "${name}=${value.to.path}")
      config.nix.registry;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = builtins.attrValues inputs.self.overlays;
  };
}
