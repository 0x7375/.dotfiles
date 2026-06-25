{
  flake.modules.nixos.keyd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      systemd.services.keyd.serviceConfig.Group = "keyd";

      services.keyd = {
        enable = true;
        keyboards =
          let
            corne = "4653:0004";
            keychron = "3434:0321";
            thinkpad = "0001:0001";
            m1 = "05ac:0281:2bd1f3de";

            mapModNumbers = mod: lib.genAttrs (map toString (lib.range 0 9)) (x: "${mod}-${x}");
            mapNumbers = lib.genAttrs (map toString (lib.range 0 9)) (x: x);

            settings = {
              control.m = "enter";

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

              compose = {
                shift = "layer(compose_shift)";

                a = "macro(compose ` a)";
                c = "macro(compose , c)";
                e = "macro(compose S-6 e)";
                i = "macro(compose S-6 i)";
                o = "macro(compose S-6 o)";
                r = "macro(compose ' e)";
                u = "macro(compose S-6 u)";
                w = "macro(compose ` e)";
                x = "macro(compose x x)";
                y = "macro(compose ` u)";

                "0" = "oneshot(compose_zero)";
                "8" = "oneshot(compose_eight)";
                equal = "oneshot(compose_equal)";
              };

              utility = {
                # numpad
                q = "1";
                w = "2";
                e = "3";
                a = "4";
                s = "5";
                d = "6";
                z = "7";
                x = "8";
                c = "9";
                leftmeta = "0";
                leftalt = "0";

                # media
                right = "nextsong";
                left = "previoussong";
                up = "volumeup";
                down = "volumedown";
                space = "playpause";

                backspace = "print";
                capslock = "capslock";
              };

              compose_zero_shift.e = "macro(compose S-o S-e)";
              compose_eight."8" = "macro(compose 8 8)";

              compose_shift = {
                a = "macro(compose S-6 a)";
                c = "macro(compose , S-c)";
                e = "macro(compose S-' e)";
                i = "macro(compose S-' i)";
                o = "macro(compose S-' o)";
                r = "macro(compose ' S-e)";
                u = "macro(compose m u)";
                w = "macro(compose ` S-e)";

                "," = "macro(compose S-, S-,)";
                "." = "macro(compose S-. S-.)";
              };

              compose_equal = {
                e = "macro(compose = e)";
                l = "macro(compose - l)";
                y = "macro(compose - y)";
              };

              compose_zero = {
                "0" = "macro(compose o o)";
                c = "macro(compose o c)";
                e = "macro(compose o e)";
                shift = "layer(compose_zero_shift)";
              };

              alt = mapModNumbers "A";
              meta = mapModNumbers "M";
            };

            overload-caps = {
              main.capslock = "overload(control, esc)";
              # ignores tap behaviour if no key was pressed and time is over timeout
              global.overload_tap_timeout = 250;
            };

            swap-meta.main = {
              leftalt = "layer(meta)";
              leftmeta = "layer(alt)";
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

            merge = lib.recursiveUpdate;
          in
          {
            external = {
              ids = [
                keychron
                corne
              ];
              settings = merge settings {
                main.rightalt = "oneshot(compose)";
                main.rightcontrol = "oneshot(utility)";
              };
              inherit extraConfig;
            };
            thinkpad = {
              ids = [ thinkpad ];
              settings = merge (merge (merge settings swap-meta) overload-caps) {
                main.rightalt = "oneshot(compose)";
                main.rightcontrol = "oneshot(utility)";
              };
              inherit extraConfig;
            };
            m1 = {
              ids = [ m1 ];
              settings = merge (merge settings overload-caps) {
                main.rightmeta = "oneshot(compose)";
                main.rightalt = "oneshot(utility)";
              };
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

      packages = with pkgs; [
        keyd
      ];

      users.users.${config.me.user}.extraGroups = [ "keyd" ];
      users.groups.keyd = { };

      services.udev.extraRules = # bash
        ''
          SUBSYSTEM=="input", \
          ACTION=="add", \
          ATTR{name}!="keyd virtual*", \
          RUN+="${lib.getExe' pkgs.systemd "systemctl"} try-restart keyd.service", \
        '';
    };
}
