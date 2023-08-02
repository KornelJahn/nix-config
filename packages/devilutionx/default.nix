{ pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
if system == "x86_64-linux" then
  let
    pname = "devilutionx";
    version = "1.5.0";
  in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;
    src = pkgs.fetchurl {
      url = "https://github.com/diasurgical/devilutionX/releases/download/${version}/devilutionx-linux-x86_64.appimage";
      sha256 = "sha256-mFHMXYnB5DUmbZfIb7MFDUoo4v4wTWiS+/Yo+QR2gQM=";
    };
  }
else
  pkgs.devilutionx # Fallback, e.g. on aarch64
