{
  pkgs,
  config,
  lib,
  mkNixos,
  ...
}:

let
  inherit (lib) getExe getExe';
in
lib.mkIf config.me.wm.enable (mkNixos {
  xdg.terminal-exec = {
    enable = true;
    settings.default = [
      "foot.desktop"
      "Alacritty.desktop"
    ];
  };

  me.wm = {
    bindings =
      let
        change-brightness = getExe pkgs.my.change-brightness;
        screenshot = getExe pkgs.my.screenshot;
        term = getExe pkgs.${config.me.wm.terminal};

        openNote =
          let
            dir = "$HOME/notes";
          in
          pkgs.writeShellScript "open-note"
            # bash
            ''
              note=$(ls ${dir} | sed 's/\.md$//' | ${getExe pkgs.bemenu} -p "NOTE")
              [ -n "$note" ] && echo $EDITOR "${dir}/$note.md"
            '';

        btToggle =
          let
            airpods = "D4:68:AA:88:8E:32";
          in
          pkgs.writeShellScript "bluetooth-toggle"
            # bash
            ''
              if ${getExe' pkgs.bluez "bluetoothctl"} info ${airpods} | grep -q "Connected: yes"; then
                echo -e "disconnect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
              else
                echo -e "connect ${airpods}\nquit" | ${getExe' pkgs.bluez "bluetoothctl"}
              fi
            '';
      in
      {
        XF86MonBrightnessUp = "${change-brightness} up";
        XF86MonBrightnessDown = "${change-brightness} down";
        Print = "${screenshot} region";
        "Alt+Sys_Req" = "${screenshot} window";
        "Shift+Print" = "${screenshot} monitor";

        "Mod+Shift+n" = "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan";
        "Mod+t" = "${term} -e ${getExe pkgs.my.tmux-sessionizer} ~/";
        "Mod+Shift+t" = term;

        "Mod+s" = "${term} -e ${getExe pkgs.my.tmux-sshr}";
        "Mod+Shift+s" = getExe pkgs.my.swap-theme;
        "Mod+e" = "${term} -e ${getExe pkgs.lf}";
        "Mod+Shift+e" = "${term} -e sudo ${getExe pkgs.lf}";
        "Mod+m" = "${term} -e $(${openNote})";
        "Mod+n" =
          "${term} -e ${getExe pkgs.zsh} -c '${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && unset COLORTERM && TERM=xterm-old ${getExe' pkgs.networkmanager "nmtui"}'";
        "Mod+Shift+b" = btToggle;
        "Mod+d" = "${getExe pkgs.j4-dmenu-desktop} --no-generic -d '${getExe pkgs.bemenu} -p \"DESKTOP\"'";
        "Mod+p" = getExe pkgs.my.powermenu;

        "Mod+Shift+c" = {
          cmd = getExe pkgs.my.color-picker;
          release = true;
        };
        "Mod+Shift+m" = {
          cmd = "${term} -e sh -c '${getExe' pkgs.xprop "xprop"}; exec $SHELL'";
          release = true;
        };
      };

    startup.dbus-update.cmd = "${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all";
  };

  activation = getExe pkgs.my.generate-icons;
  services.dbus.enable = true;
})
