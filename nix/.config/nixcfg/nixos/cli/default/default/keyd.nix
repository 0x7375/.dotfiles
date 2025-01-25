{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
          global = {
            overload_tap_timeout = 100;
          };
        };
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
      SUBSYSTEM=="input", ACTION=="add", ATTR{name}!="keyd virtual*", RUN+="${pkgs.systemd}/bin/systemctl try-restart keyd.service"
    '';

  systemd.services.keyd.serviceConfig = {
    Group = "keyd";
  };
}
