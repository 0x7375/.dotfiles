{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf (config.me.wm.displayServer == "xorg") {
  packages = [ pkgs.polybar ];

  hj.xdg.config.files."polybar/config.ini".text = ''
    [bar/main]
    background=''${xrdb:bg0_dark}
    border-size=0pt
    enable-ipc=true
    font-0=Mononoki Nerd Font:pixelsize=${toString config.me.barFontSize};4
    foreground=''${xrdb:fg0}
    height=${toString config.me.barHeight}
    module-margin=0
    modules-center=i3
    modules-left=xwindow
    modules-right=cpu memory battery network datetime
    padding=1
    radius=0
    separator=" "
    separator-foreground=''${xrdb:fg0}
    separator-padding=1
    width=100%

    [module/battery]
    battery=BAT0
    format-charging=<label-charging>
    format-discharging=<label-discharging>
    label-charging=pow: ~%percentage%%
    label-discharging=pow: %percentage%%
    label-full=pow: %percentage%%
    label-low=pow: %percentage%%
    poll-interval=5
    type=internal/battery

    [module/cpu]
    format=cpu: <label>
    interval=3
    type=internal/cpu

    [module/datetime]
    date=%a %d %b - %H:%M
    interval=1
    type=internal/date

    [module/i3]
    label-focused=%index%
    label-focused-foreground=''${xrdb:fg0}
    label-focused-padding=1
    label-unfocused=%index%
    label-unfocused-foreground=''${xrdb:bg2}
    label-unfocused-padding=1
    label-urgent=%index%
    label-urgent-foreground=''${xrdb:bg2}
    label-urgent-padding=1
    label-visible=%index%
    label-visible-foreground=''${xrdb:bg2}
    label-visible-padding=1
    pin-workspaces=true
    type=internal/i3

    [module/memory]
    format=ram: <label>
    interval=3
    type=internal/memory

    [module/network]
    format-connected=net: <label-connected>
    interface=wlan0
    label-connected=%essid%
    label-connected-maxlen=8
    label-disconnected=net: x
    label-disconnected-foreground=''${xrdb:fg3}
    type=internal/network

    [module/nix]
    format=~${config.me.hostname}
    type=custom/text

    [module/tray]
    type=internal/tray

    [module/xwindow]
    label=" %title%"
    label-empty=~${config.me.hostname}
    label-maxlen=50
    type=internal/xwindow

    [settings]
    pseudo-transparency=true
    screenchange-reload=true
  '';
}
