{ config, ... }:

{
  systemd.user.tmpfiles.rules = [
    "f /home/${config.me.user}/.local/state/current_theme 0644 ${config.me.user} users - - dark"
  ];
}
