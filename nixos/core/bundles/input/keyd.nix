{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.me.keyd.enable {
  nixpkgs.overlays = [
    (final: prev: {
      keyd = prev.keyd.overrideAttrs (old: rec {
        version = "0cbe717b63c73de7872013b0834d90d802047546";
        src = pkgs.fetchFromGitHub {
          owner = old.src.owner;
          repo = old.src.repo;
          rev = version;
          sha256 = "NfdOjLgMU7CJup2MeBaK/uADVyfWPNLGPNm3ahwqrRY=";
        };
      });
    })
  ];

  services.keyd = {
    enable = true;
    keyboards = {
      global = {
        ids = [ "3434:0321" ];
      };
      default = {
        ids = [
          "*"
          "-3434:0321"
        ];
        settings = {
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
      };
    };
  };

  systemd.services.keyd.restartIfChanged = false;

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
      RUN+="${pkgs.systemd}/bin/systemctl try-restart keyd.service", \
    '';

  systemd.services.keyd.serviceConfig = {
    Group = "keyd";
  };
}
