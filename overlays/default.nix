{ self, nixpkgs-unstable, ... }:

{
  unstablePkgs = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config = { inherit (prev.config) allowUnfree; };
    };
  };

  myPackages = final: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
    in
    { my = self.packages.${system}; };
}
