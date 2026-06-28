{ pkgs, config, ... }:

let
  sdk = config.android.androidSdk;
in
{
  android = {
    enable = true;
    tools.version = "26.1.1";
    flutter.enable = true;
    platforms.version = [ "32" "34" "36" ];
    buildTools.version = [ "35.0.0" ];
    cmdLineTools.version = "11.0";
  };

  languages.dart.enable = true;

  tasks = {
    "aurevoir-app:doctor" = {
      description = "Run Flutter doctor";
      exec = "flutter doctor";
    };
    "aurevoir-app:clean" = {
      description = "Clean the build artifacts";
      exec = "flutter clean";
    };
    "aurevoir-app:install-dependencies" = {
      description = "Install Flutter dependencies";
      exec = "flutter pub get";
    };
    "aurevoir-app:build:linux" = {
      description = "Build the Linux app";
      after = [ "aurevoir-app:install-dependencies" ];
      exec = "flutter build linux --release";
    };
    "aurevoir-app:build:android" = {
      description = "Build the Android app";
      after = [ "aurevoir-app:install-dependencies" ];
      exec = "flutter build apk --release";
    };
  };
}