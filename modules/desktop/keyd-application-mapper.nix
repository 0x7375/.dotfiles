{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.me.desktop.enable && config.me.keyd.enable) {
  hj.xdg.config.files."i3/config".text =
    "$exec_always ${lib.getExe' pkgs.systemd "systemctl"} --user restart keyd-application-mapper";

  # wayland.windowManager.hyprland.settings.exec = [
  #   "${lib.getExe' pkgs.systemd "systemctl"} --user restart keyd-application-mapper"
  # ];

  systemd.user.services.keyd-application-mapper = {
    description = "keyd application mapper";
    path = [ pkgs.keyd ];

    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.keyd "keyd-application-mapper"}";
      Restart = "always";
    };
  };

  hj.xdg.config.files."keyd/app.conf".text =
    let
      default =
        # toml
        ''
          control.h = backspace
          control.p = up
          control.n = down
          f7 = A-right
          f8 = A-left
          control.j = C-tab
          control.k = C-S-tab
          control.w = C-backspace
          control.d = C-w
          alt.f = C-right
          alt.b = C-left
        '';

      defaultWithEnter = default + "\ncontrol.m = enter";

      apps = [
        "1password"
        "discord"
        "ssh-askpass"
        "polkit-gnome-authentication-agent-1"
        "spotify"
      ];

      appConfigs = builtins.concatStringsSep "\n\n" (map (app: "[${app}]\n${defaultWithEnter}") apps);
    in
    # toml
    ''
      [librewolf]
      ${defaultWithEnter}
      control.e = f6

      [zen-beta]
      ${defaultWithEnter}
      control.e = f6

      # make fullscreen toggle compact mode aswell
      meta.f = macro(A-c M-f)

      [io-ente-auth]
      ${defaultWithEnter}
      control.e = macro(tab tab tab enter)

      [copyq]
      ${default}
      control.m = macro(enter 20ms M-q)

      ${appConfigs}
    '';
}
