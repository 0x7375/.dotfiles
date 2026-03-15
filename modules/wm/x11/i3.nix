{
  mkNixos,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) getExe getExe';

  mkI3Bind =
    name: cfg:
    let
      parts = lib.splitString "+" name;
      key = lib.last parts;
      modStr = lib.concatStringsSep "+" (
        map (
          m:
          if m == "Mod" then
            "$super"
          else if m == "Alt" then
            "$alt"
          else
            m
        ) (lib.init parts)
      );

      prefix = if cfg.release then "bindsym --release" else "bindsym";
      bind = if modStr == "" then key else "${modStr}+${key}";
    in
    "${prefix} ${bind} $exec ${cfg.cmd}";

  mkI3Start =
    _: cfg:
    let
      prefix = if cfg.always then "exec_always --no-startup-id" else "exec --no-startup-id";
    in
    "${prefix} ${cfg.cmd}";

  assignRules = lib.concatMapStringsSep "\n" (
    cfg: ''assign [${cfg.type}="^${cfg.name}$"] ${cfg.workspace}''
  ) config.me.wm.assign;

  floatingRules = lib.concatMapStringsSep "\n" (
    cfg:
    ''for_window [${cfg.type}="^${cfg.name}$"] floating ${if cfg.enable then "enable" else "disable"} ''
  ) config.me.wm.floating;

  startupCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList mkI3Start config.me.wm.startup);
  extraBinds = lib.concatStringsSep "\n" (lib.mapAttrsToList mkI3Bind config.me.wm.bindings);
in
lib.mkIf (config.me.wm.displayServer == "xorg") (mkNixos {
  hj.xdg.config.files."i3/config".text = ''
    set $exec exec --no-startup-id
    set $exec_always exec_always --no-startup-id

    set $alt Mod1
    set $super Mod4

    set $superdow-move-amount 40px

    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"

    # hide tab title
    font pango:monospace 0.000000
    floating_modifier $super
    default_border pixel 0
    default_floating_border pixel 1
    hide_edge_borders smart
    focus_wrapping no
    focus_follows_mouse yes
    focus_on_window_activation focus
    mouse_warping output
    workspace_layout tabbed
    workspace_auto_back_and_forth no

    set_from_resource $inactive bg0 #000000
    set_from_resource $active fg2 #000000

    #                        border    background text      indicator child_border
    client.focused           $active   $active    $active   $active   $active
    client.focused_inactive  $inactive $inactive  $inactive $inactive $inactive
    client.unfocused         $inactive $inactive  $inactive $inactive $inactive
    client.urgent            $active   $active    $active   $active   $active
    client.placeholder       $inactive $inactive  $inactive $inactive $inactive
    client.background        $inactive

    bindsym $super+Shift+r restart
    bindsym $super+h focus left
    bindsym $super+j focus down
    bindsym $super+k focus up
    bindsym $super+l focus right
    bindsym $super+q kill
    bindsym $super+f fullscreen toggle
    bindsym $super+g layout toggle splith tabbed

    bindsym $super+Return floating toggle
    bindsym $super+Shift+g focus mode_toggle

    bindsym $super+Ctrl+h move left $superdow-move-amount
    bindsym $super+BackSpace move left $superdow-move-amount

    bindsym $super+Ctrl+j move down $superdow-move-amount
    bindsym $super+Ctrl+Tab move down $superdow-move-amount

    bindsym $super+Ctrl+k move up $superdow-move-amount
    bindsym $super+Ctrl+Shift+Tab move up $superdow-move-amount

    bindsym $super+Ctrl+l move right $superdow-move-amount

    bindsym $super+c move position center

    bindsym $super+Shift+h resize shrink width 30 px or 30 ppt
    bindsym $super+Shift+j resize grow height 30 px or 30 ppt
    bindsym $super+Shift+k resize shrink height 30 px or 30 ppt
    bindsym $super+Shift+l resize grow width 30 px or 30 ppt

    bindsym $super+1 workspace $ws1
    bindsym $super+2 workspace $ws2
    bindsym $super+3 workspace $ws3
    bindsym $super+4 workspace $ws4
    bindsym $super+5 workspace $ws5
    bindsym $super+6 workspace $ws6
    bindsym $super+7 workspace $ws7
    bindsym $super+8 workspace $ws8
    bindsym $super+9 workspace $ws9
    bindsym $super+0 workspace $ws10

    bindsym $super+Shift+1 move container to workspace $ws1
    bindsym $super+Shift+2 move container to workspace $ws2
    bindsym $super+Shift+3 move container to workspace $ws3
    bindsym $super+Shift+4 move container to workspace $ws4
    bindsym $super+Shift+5 move container to workspace $ws5
    bindsym $super+Shift+6 move container to workspace $ws6
    bindsym $super+Shift+7 move container to workspace $ws7
    bindsym $super+Shift+8 move container to workspace $ws8
    bindsym $super+Shift+9 move container to workspace $ws9
    bindsym $super+Shift+0 move container to workspace $ws10

    for_window [window_role="^(About|Organizer|Preferences|bubble|page-info|pop-up|task_dialog|toolbox|webconsole|Popup)$"] floating enable
    for_window [window_type="^(dialog|menu)$"] floating enable

    for_window [title="PIN required"] border none

    for_window [class="^(Main|Matplotlib)$"] floating enable

    for_window [class=".*"] border pixel 1
    for_window [floating] move position center
    for_window [window_role="Popup"] border pixel 0

    $exec ${getExe' pkgs.i3 "i3-msg"} workspace 1

    $exec ${getExe pkgs.xset} s off -dpms
    $exec_always ${getExe' pkgs.hsetroot "hsetroot"} -solid "$(xrdb -query | grep 'bg0:' | cut -f2)"

    ${startupCmds}
    ${extraBinds}
    ${assignRules}
    ${floatingRules}
  '';

  packages = [ pkgs.libinput-gestures ];

  hj.xdg.config.files."libinput-gestures.conf".text =
    let
      xdo = getExe pkgs.xdotool;
    in
    ''
      gesture swipe left 3 i3-msg workspace next
      gesture swipe right 3 i3-msg workspace prev
      gesture swipe down 3 ${getExe pkgs.bash} -c "${xdo} key super+f; ${xdo} key alt+c"
      gesture swipe up 3 ${getExe pkgs.bash} -c "${xdo} key super+f; ${xdo} key alt+c"
    '';

  # user needs to be in the input group
  systemd.user.services.libinput-gestures = {
    path = [ pkgs.i3 ];
    partOf = [ "graphical-session.target" ];

    serviceConfig.ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
    restartTriggers = [
      "${config.hj.xdg.config.files."libinput-gestures.conf".source}"
    ];

    wantedBy = [ "graphical-session.target" ];
  };
})
