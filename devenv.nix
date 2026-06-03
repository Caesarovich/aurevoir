{ pkgs, lib, config, inputs, ... }:

{
  android = {
    enable = true;
    flutter.enable = true;
  };

  languages.dart.enable = true;
}
