{ pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
if system == "x86_64-linux" then
  let
    pname = "devilutionx";
    version = "1.5.1";
  in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;
    src = pkgs.fetchurl {
      url = "https://github.com/diasurgical/devilutionX/releases/download/${version}/devilutionx-linux-x86_64.appimage";
      sha256 = "sha256-LKNftM35VWSes0KNwO9vBOZAzfIyK3ZdMFQOLixyX68=";
    };
  }
else
  pkgs.devilutionx # Fallback, e.g. on aarch64
