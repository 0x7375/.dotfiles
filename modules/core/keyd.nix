{
  flake.nixos.keyd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.keyd = {
        enable = true;
        keyboards =
          let
            corne = "4653:0004";
            keychron = "3434:0321";
            thinkpad = "0001:0001";

            mapModNumbers = mod: lib.genAttrs (map toString (lib.range 0 9)) (x: "${mod}-${x}");
            mapNumbers = lib.genAttrs (map toString (lib.range 0 9)) (x: x);

            settings = {
              main = {
                shift = "layer(pwerty_shift)";
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

              "pwerty_shift:S" = mapNumbers // {
                "`" = "!";
                "-" = "*";
                "equal" = "@";
                "[" = "_";
                "]" = "#";
              };

              "qwerty_shift:S" = {
                "`" = "~";
                "1" = "!";
                "2" = "@";
                "3" = "#";
                "4" = "$";
                "5" = "%";
                "6" = "^";
                "7" = "&";
                "8" = "*";
                "9" = "(";
                "0" = ")";
                "-" = "_";
                "equal" = "+";
                "[" = "{";
                "]" = "}";
              };

              "qwerty:layout" = mapNumbers // {
                shift = "layer(qwerty_shift)";

                "leftalt+leftshift+space" = "setlayout(main)";
                "leftmeta+leftshift+space" = "setlayout(main)";

                "`" = "`";
                "-" = "-";
                "equal" = "=";
                "[" = "[";
                "]" = "]";
              };

              alt = mapModNumbers "A";
              meta = mapModNumbers "M";
            };

            qol = {
              main = {
                capslock = "overload(control, esc)";
                leftalt = "layer(meta)";
                leftmeta = "layer(alt)";
              };
              global = {
                # ignores tap behaviour if no key was pressed and time is over timeout
                overload_tap_timeout = 250;
              };
            };

            extraConfig =
              let
                range = fn: lib.concatMapStringsSep "\n" fn (lib.range 0 9);
                mapModifier = mod: range (i: "${toString i} = ${mod}-S-${toString i}");
              in
              ''
                [alt+pwerty_shift]
                space = setlayout(qwerty)
                ${mapModifier "A"}

                [meta+pwerty_shift]
                space = setlayout(qwerty)
                ${mapModifier "M"}

                [alt+qwerty_shift]
                space = setlayout(main)

                [meta+qwerty_shift]
                space = setlayout(main)
              '';
          in
          {
            external = {
              ids = [
                keychron
                corne
              ];
              inherit settings extraConfig;
            };
            laptop = {
              ids = [ thinkpad ];
              settings = lib.recursiveUpdate settings qol;
              inherit extraConfig;
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

      packages = [ pkgs.keyd ];

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
    };
}
