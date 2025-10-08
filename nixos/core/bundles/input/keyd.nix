{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.keyd.enable {
  services.keyd = {
    enable = true;
    keyboards =
      let
        corne = "4653:0004";
        keychron = "3434:0321";
        thinkpad = "0001:0001";
        pwerty = {
          main = {
            "`" = "^";
            "1" = "+";
            "2" = "[";
            "3" = "{";
            "4" = "(";
            "5" = "&";
            "6" = "=";
            "7" = ")";
            "8" = "}";
            "9" = "]";
            "0" = "%";
            "-" = "~";
            "equal" = "$";
            "[" = "-";
            "]" = "`";
          };
          shift = {
            "`" = "!";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "0" = "0";
            "-" = "*";
            "equal" = "@";
            "[" = "_";
            "]" = "#";
          };
        };
        qol = {
          main = {
            capslock = "overload(control, esc)";
            alt = "layer(meta)";
            meta = "layer(alt)";
          };
          global = {
            # ignores tap behaviour if no key was pressed and time is over timeout
            overload_tap_timeout = 250;
          };
        };
      in
      {
        external = {
          ids = [
            keychron
            corne
          ];
          settings = pwerty;
        };
        laptop = {
          ids = [ thinkpad ];
          settings = lib.recursiveUpdate qol pwerty;
        };
      };
  };

  # Optional, but makes sure that when you type the make palm rejection work with keyd
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  users.users.${config.me.user}.extraGroups = [ "keyd" ];
  users.groups.keyd = { };

  services.udev.extraRules = # bash
    ''
      SUBSYSTEM=="input", \
      ACTION=="add", \
      ATTR{name}!="keyd virtual*", \
      RUN+="${lib.getExe' pkgs.systemd "systemctl"} try-restart keyd.service", \
    '';

  systemd.services.keyd.serviceConfig = {
    Group = "keyd";
  };
}
