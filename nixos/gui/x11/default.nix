{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.me.gui.displayServer == "xorg") {
  hj.xdg.config.files."zsh/.zshrc".text =
    lib.mkBefore ''[[ $(tty) == "/dev/tty1" ]] && exec startx &> /dev/null'';

  services = {
    picom = {
      enable = true;
      shadow = false;
      fade = false;
      vSync = true;
      backend = "glx";
    };

    xbanish.enable = true; # hide mouse cursor when typing

    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];

      xkb.options = "compose:ralt";
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          xdo
          xclip
          xsel
          xdotool
        ];
      };
    };
  };
  systemd.user.services.numlock = {
    description = "Numlock";
    after = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.numlockx}/bin/numlockx on";
      StandardInput = "tty";
      RemainAfterExit = "yes";
    };
  };
}
