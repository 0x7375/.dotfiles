{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
  programs = {
    dconf.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 5 --keep-since 7d";
    };

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.me.user ];
    };
  };
}
