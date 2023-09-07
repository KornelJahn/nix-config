# Render an SVG file into a PNG wallpaper with given resolution, optionally
# colorized using a selected base16 color scheme.

{
  pkgs,
  svgTemplate, # SVG with optional base16 color tokens such as ${base00}
  colorscheme ? { }, # chosen nix-colors base16 color scheme
  width ? 1920, # fixed width of the generated PNG
}:

let
  inherit (pkgs) lib;
  svgName = builtins.head
    (lib.splitString "." (builtins.baseNameOf (toString svgTemplate)));
  exports = builtins.concatStringsSep "\n"
    (lib.mapAttrsToList (n: v: "export ${n}=${v}") colorscheme.colors);
in
pkgs.stdenvNoCC.mkDerivation {
  name = "${svgName}-wallpaper";
  src = svgTemplate;
  dontUnpack = true;
  buildInputs = [ pkgs.inkscape pkgs.gettext ];
  buildPhase = ''
    ${exports}
    envsubst < "$src" > wallpaper.svg
    inkscape \
      --export-type=png \
      --export-width=${toString width} \
      --export-filename=wallpaper.png \
      wallpaper.svg
  '';
  installPhase = ''
    install -Dm0644 wallpaper.png $out
  '';
}
