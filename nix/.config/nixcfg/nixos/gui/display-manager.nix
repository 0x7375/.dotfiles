{
  lib,
  myLib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.gui.enable {
  environment.systemPackages = [
    (pkgs.where-is-my-sddm-theme.override {
      variants = [ "qt5" ];
      themeConfig.General = {
        hideCursor = true;
        passwordCursorColor = myLib.palette.fg0;
        passwordTextColor = myLib.palette.fg0;
      };
    })
  ];

  services.displayManager = {
    sddm = {
      enable = true;
      theme = "where_is_my_sddm_theme_qt5";
      extraPackages = with pkgs; [
        libsForQt5.qt5.qtgraphicaleffects
      ];
      settings = {
        Autologin = {
          Session = "none+i3";
          User = config.me.user;
        };
      };
    };
    autoLogin = {
      enable = true;
      user = config.me.user;
    };
    defaultSession = "none+i3";
    # ly = {
    #   enable = true;
    #   settings = {
    #     hide_key_hints = true;
    #     clear_password = true;
    #   };
    # };
  };
}
