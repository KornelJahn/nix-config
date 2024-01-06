{
  description = "Personal NixOS and Home Manager configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      inherit (self) outputs;
      specialArgs = { inherit inputs outputs; };
      extraSpecialArgs = specialArgs;
      systems = [ "x86_64-linux" ];
      hosts = [
        "b550"
        "c236m"
        "x13"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
      forEachPkgs = f: forEachSystem (sys: (f nixpkgs.legacyPackages.${sys}));
      mkNixosConfig = host: {
        "${host}" = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./nixos/configs/${host}.nix ];
        };
      };
      mkHomeConfig = user: host: {
        "${user}@${host}" = home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs;
          inherit (self.nixosConfigurations.${host}) pkgs;
          modules = [ ./home/configs/${user}-at-${host}.nix ];
        };
      };
    in
    {
      lib = import ./lib inputs;
      overlays = import ./overlays inputs;
      nixosModules.default = import ./nixos/modules;
      homeModules.default = import ./home/modules;
      devShells = self.lib.mkInstallerShells self.nixosConfigurations;
      formatter = forEachPkgs (pkgs: pkgs.nixpkgs-fmt);

      packages = self.lib.recursiveMergeAttrs [
        (forEachPkgs (import ./packages))
        # WORKAROUND: add HM configurations as packages to be checked by
        # `nix flake check`
        (self.lib.gatherHomeCfgActivationPkgs self.homeConfigurations)
      ];

      nixosConfigurations = self.lib.recursiveMergeAttrs
        (map mkNixosConfig hosts);

      homeConfigurations = self.lib.recursiveMergeAttrs
        (map (mkHomeConfig "korn") hosts);
    };
}
