{ self, nixpkgs, disko, ... } @ inputs:

let
  inherit (nixpkgs) lib;

  recursiveMergeAttrs = attrsList:
    builtins.foldl' lib.recursiveUpdate { } attrsList;

  mkInstallerShell = name: nixosConfiguration:
    let
      inherit (nixosConfiguration.pkgs.stdenv.hostPlatform) system;
      inherit (nixosConfiguration) config pkgs;

      # Only provide an installer shell to those hosts that have a disko config
      shell =
        if (! builtins.hasAttr "disko" config)
        then null
        else import ../nixos/installer/shell.nix {
          inherit config pkgs inputs;
          diskoPkgs = disko.packages.${system};
        };
    in
    lib.optionalAttrs (shell != null) { ${system}.${name} = shell; };

  getHomeCfgActivationPkg = name: homeConfiguration:
    let
      inherit (homeConfiguration.pkgs.stdenv.hostPlatform) system;
    in
    { ${system}.${name} = homeConfiguration.activationPackage; };
in
{
  inherit recursiveMergeAttrs;

  filterExistingGroups = config: groups:
    builtins.filter (x: builtins.hasAttr x config.users.groups) groups;

  mkInstallerShells = nixosConfigurations:
    recursiveMergeAttrs (
      builtins.filter
        (x: x != { })
        (lib.mapAttrsToList mkInstallerShell nixosConfigurations)
    );

  gatherHomeCfgActivationPkgs = homeConfigurations:
    recursiveMergeAttrs (
      lib.mapAttrsToList getHomeCfgActivationPkg homeConfigurations
    );

  mkWallpaper = import ./mk-wallpaper.nix;
}
