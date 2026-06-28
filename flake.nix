{
  description = "Reproducible Flutter Linux package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.flutterPackages.stable.buildFlutterApplication {
          pname = "aurevoir";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;

          pubspecLock = pkgs.lib.importJSON ./pubspec.lock.json;

          meta = with pkgs.lib; {
            description = "Aurevoir Flutter app";
            platforms = platforms.linux;
            mainProgram = "aurevoir";
          };
        };
      });
}