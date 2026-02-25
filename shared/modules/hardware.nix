{ lib, ... }:

{
  options.asta.hardware = {
    battery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Does this system have a rechargable battery.
      '';
    };

    mouse = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Does this system have a mouse.
        If false, assumes a trackpad / touchscreen is being used.
      '';
    };

    keyboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Does this system have a keyboard.
        If false, assumes a touchscreen is being used.
      '';
    };

    monitors = lib.sublist {
      options = {
        portname = lib.mkOption {
          type = lib.types.str;
          example = "DP-1";
          description = ''The portname of the monitor.'';
        };
        scale = lib.mkOption {
          type = lib.types.numbers.positive;
          default = 1.0;
          example = 2.0;
          description = ''
            Scale factor from the default dpi of 96.0.
          '';
        };
        width = lib.mkOption {
          type = lib.types.ints.positive;
          example = 1920;
          description = ''
            Screen width.
          '';
        };
        height = lib.mkOption {
          type = lib.types.ints.positive;
          example = 1080;
          description = ''
            Screen height.
          '';
        };
        refreshRate = lib.mkOption {
          type = lib.types.numbers.positive;
          default = 60;
          example = 144;
          description = ''
            Screen refresh rate.
          '';
        };
        x = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        y = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
      };
    };
  };
}
