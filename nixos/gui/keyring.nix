{ lib, config, ... }:

lib.mkIf config.me.gui.enable {
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
