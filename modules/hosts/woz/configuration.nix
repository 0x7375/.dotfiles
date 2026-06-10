{ inputs, ... }:

{
  flake.modules.nixos.woz =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib) getExe getExe';
    in
    {
      nix.settings = {
        extra-substituters = [ "https://nixos-apple-silicon.cachix.org" ];
        extra-trusted-public-keys = [
          "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
        ];
      };

      imports = [
        inputs.apple-silicon.nixosModules.apple-silicon-support
      ];

      nix.settings = {
        cores = 4;
        max-jobs = 1;
      };

      boot.extraModprobeConfig = "options hid_apple swap_fn_leftctrl=1";

      hardware.brillo.enable = true;
      services.udev.extraRules =
        let
          notify = pkgs.writeShellApplication {
            name = "charging-notify";
            runtimeInputs = with pkgs; [
              gnugrep
              acpi
              libnotify
            ];
            text = ''
              [[ $# != 1 ]] && printf '0 or 1 must be passed as an argument.\nUsage: %s 0|1\n' "$0" && exit

              export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"

              battery_charging=$1
              battery_level=$(acpi -b | grep -E "remaining|zero|until" | grep -P -o '[0-9]+(?=%)')

              if [[ $battery_charging -eq 1 ]]; then
                ${lib.getExe pkgs.my.notify} "Charging" "$battery_level% of battery charged." -i "battery-charging-2" 
              elif [[ $battery_charging -eq 0 ]]; then
                ${lib.getExe pkgs.my.notify} "Discharging" "$battery_level% of battery remaining." -i "battery"
              fi
            '';
          };
        in
        # bash
        ''
          # Allow video group to change screen brightness
          ACTION=="add", \
          SUBSYSTEM=="backlight", \
          KERNEL=="amdgpu_bl0", \
          RUN+="${getExe' pkgs.coreutils "chgrp"} video /sys/class/backlight/%k/brightness", \
          RUN+="${getExe' pkgs.coreutils "chmod"} g+w /sys/class/backlight/%k/brightness"

          # Notifications on power plug/unplug
          ACTION=="change", \
          SUBSYSTEM=="power_supply", \
          ATTR{type}=="Mains", \
          ATTR{online}=="0", \
          ENV{WAYLAND_DISPLAY}="wayland-1", \
          ENV{XDG_RUNTIME_DIR}="/run/user/${toString config.me.uid}", \
          RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe notify} 0'"

          ACTION=="change", \
          SUBSYSTEM=="power_supply", \
          ATTR{type}=="Mains", \
          ATTR{online}=="1", \
          ENV{WAYLAND_DISPLAY}="wayland-1", \
          ENV{XDG_RUNTIME_DIR}="/run/user/${toString config.me.uid}", \
          RUN+="${getExe' pkgs.su "su"} ${config.me.user} -c '${getExe notify} 1'"

          # Automatically lock when security key is unplugged
          ACTION=="remove",\
          SUBSYSTEM=="usb",\
          ENV{DEVTYPE}=="usb_interface",\
          ENV{INTERFACE}=="11/0/0",\
          ENV{PRODUCT}=="349e/24/100",\
          RUN+="${getExe' pkgs.systemd "loginctl"} lock-sessions"
        '';

      services.upower.enable = true;

      packages = with pkgs; [ acpi ];

      services.acpid = {
        enable = true;
        handlers =
          let
            turnOffScreen = "${lib.getExe pkgs.wlopm} --off \"*\"";
          in
          {
            lid-close = {
              event = "button/lid LID close";
              action =
                # bash
                ''
                  ${turnOffScreen}

                  if ${lib.getExe' pkgs.procps "pgrep"} -x waylock > /dev/null; then
                    systemctl hibernate
                  fi
                '';
            };
            lid-open = {
              event = "button/lid LID open";
              action = turnOffScreen;
            };
          };
      };

      services.logind.settings.Login.HandleLidSwitch = "ignore";

      # systemd.services.disable-lid-wakeup = {
      #   description = "Disable lid switch as wake source for suspend/hibernate";
      #   wantedBy = [ "multi-user.target" ];
      #   after = [ "multi-user.target" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     ExecStart = "${getExe pkgs.bash} -c 'echo LID > /proc/acpi/wakeup'";
      #     RemainAfterExit = true;
      #   };
      # };

      me.desktop.startup.idle =
        let
          screen = state: "${lib.getExe pkgs.wlopm} --${state} \"*\"";

          lock = pkgs.writeShellApplication {
            name = "lock";
            bashOptions = [ ];
            runtimeInputs = with pkgs; [
              procps
              waylock
            ];
            text =
              # bash
              ''
                if pidof waylock > /dev/null; then
                  exit 0
                fi

                current_ssid=$(${getExe' pkgs.wirelesstools "iwgetid"} -r)
                home_ssid=$(cat "${config.sops.secrets.home_ssid.path}")

                [[ "$current_ssid" == "$home_ssid" ]] && exit 0

                browser_was_open=false
                pgrep -x "$BROWSER" > /dev/null && browser_was_open=true
                pkill -x "$BROWSER" || true

                ( sleep 300 && systemctl hibernate ) &
                HIBERNATE_PID=$!

                if grep -q "closed" /proc/acpi/button/lid/*/state 2> /dev/null; then
                  systemctl hibernate
                fi
                  
                waylock -fork-on-lock

                (
                  while pidof waylock >/dev/null; do sleep 1; done
                  kill "$HIBERNATE_PID" 2>/dev/null || true
                  $browser_was_open && "$BROWSER" &
                ) &
              '';
          };
        in
        # bash
        pkgs.writeShellScript "idle" ''
          ${lib.getExe pkgs.swayidle} -w \
              timeout 300 '${screen "off"}' resume '${screen "on"}' \
              timeout 600 '${getExe lock}' \
              timeout 1800 'systemctl hibernate' \
              before-sleep '${getExe lock}' \
              after-resume '${screen "on"}' \
              lock '${getExe lock}'
        '';

      time.timeZone = "Europe/Paris";

      system.stateVersion = "25.11";
    };
}
