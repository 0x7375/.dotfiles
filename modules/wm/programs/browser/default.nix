{ lib, ... }:

{
  options.me.wm = {
    refreshRate = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Refresh rate (for smooth scrolling settings in zen)";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      default = "helium";
      description = "Default browser";
    };
  };
}
