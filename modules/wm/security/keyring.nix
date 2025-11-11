{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome = {
    description = "GNOME PolicyKit Agent";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    wantedBy = [ "graphical-session.target" ];

    serviceConfig.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  };

  services.gnome.gnome-keyring.enable = true;

  packages = with pkgs; [
    polkit_gnome
    libsecret
    libgnome-keyring
  ];

  systemd.user.tmpfiles.rules =
    let
      content =
        builtins.replaceStrings [ "\n" ] [ "\\n" ]
          # toml
          ''
            [keyring]
            display-name=login
            ctime=1744318225
            mtime=0
            lock-on-idle=false
            lock-after=false
          '';
    in
    [
      "d ${config.me.home}/.local/share/keyrings 0700 ${config.me.user} users - -"
      "f ${config.me.home}/.local/share/keyrings/login.keyring 0600 ${config.me.user} users - ${content}"
    ];

  hj.xdg.data.files."keyrings/default".text = "login";
}
