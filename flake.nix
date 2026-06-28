{
  description = "Flutter app with devenv + flakes";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "path:/home/cesar/Nextcloud/Code/aurevoir/.devenv/root";
      flake = false;
    };
    build-artifacts = {
      url = "path:/home/cesar/Nextcloud/Code/aurevoir/build";
      flake = false;
    };
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, devenv, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devenv.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { config, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          _module.args.pkgs = pkgs;

          devenv.shells.default = {
            imports = [ ./devenv.nix ];
          };

          packages.linux-app = pkgs.stdenvNoCC.mkDerivation {
            pname = "aurevoir-linux-app";
            version = "1.0.0";
            src = inputs.build-artifacts;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p "$out"
              cp -r linux/x64/release/bundle/. "$out"/
            '';
          };

          packages.android-app = pkgs.stdenvNoCC.mkDerivation {
            pname = "aurevoir-android-app";
            version = "1.0.0";
            src = inputs.build-artifacts;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p "$out"
              cp app/outputs/flutter-apk/app-release.apk "$out"/aurevoir.apk
            '';
          };
        };
    };
}