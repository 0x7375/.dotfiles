{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  users.users.${config.me.user}.extraGroups = [ "adbusers" ];

  programs = {
    adb.enable = true;
    dconf.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 5 --keep-since 7d";
    };

    _1password.enable = true;
    _1password-gui = {
      package = pkgs._1password-gui;
      enable = true;
      polkitPolicyOwners = [ config.me.user ];
    };

    wireshark.enable = true;

    localsend = {
      enable = true;
      package = pkgs.auto.localsend;
    };
  };
}
