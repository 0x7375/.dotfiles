{
  flake.nixos.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    lib.mkMerge [
      {
        nixpkgs.overlays = [
          (final: prev: {
            pear-desktop = final.nur.repos.lonerOrz.pear-desktop.overrideAttrs (oldAttrs: {
              installPhase = ''
                find dist -type f -name "*.js" -exec sed -i 's/openDevTools()/closeDevTools()/g' {} +

                ${oldAttrs.installPhase}
              '';
            });
          })
        ];

        me.desktop.bindings =
          let
            playerctl = lib.getExe pkgs.playerctl;
            change-volume = lib.getExe (
              pkgs.writeShellApplication {
                name = "change-volume";
                runtimeInputs = with pkgs; [
                  pamixer
                  libnotify
                ];
                text = ''
                  send_notification() {
                      local -ri volume=$(pamixer --get-volume)

                      local icon
                      if [[ $volume -gt 70 ]]; then
                          icon="high"
                      elif [[ $volume -gt 40 ]]; then
                          icon="medium"
                      else
                          icon="low"
                      fi

                      notify-send -a "volume" -t 2000 -r 9993 -u low -i "volume-$icon" -h int:value:"$volume" "Volume" "Currently at ''${volume}%"
                  }

                  send_muted() {
                      notify-send -a "volume" -t 2000 -r 9993 -u low -i "volume-mute" "Muted"
                  }

                  case $1 in
                  up)
                      pamixer -i 5
                      send_notification
                      ;;
                  down)
                      pamixer -d 5
                      send_notification
                      ;;
                  mute)
                      pamixer -t
                      if [[ $(pamixer --get-mute) == true ]]; then
                          send_muted
                      else
                          send_notification
                      fi
                      ;;
                  esac
                '';
              }
            );
          in
          {
            XF86AudioRaiseVolume = "${change-volume} up";
            XF86AudioLowerVolume = "${change-volume} down";
            XF86AudioMute = "${change-volume} mute";
            XF86AudioNext = "${playerctl} next";
            XF86AudioPrev = "${playerctl} previous";
            XF86AudioPlay = "${playerctl} play-pause";
            XF86AudioMicMute = "${playerctl} play-pause";
            Prior = "${playerctl} previous";
            Next = "${playerctl} next";
          };

        packages = with pkgs; [
          playerctl
          pwvucontrol
          pavucontrol

          pamixer
          pear-desktop
        ];

        services.udev.extraRules = # bash
          let
            removeRule = subsystem: ''
              ACTION=="remove", \
              SUBSYSTEM=="${subsystem}", \
              ENV{DISPLAY}=":0", \
              ENV{XAUTHORITY}="/run/user/${toString config.me.uid}/Xauthority", \
              RUN+="${lib.getExe' pkgs.su "su"} ${config.me.user} -c '${lib.getExe pkgs.playerctl} pause --all-players'"
            '';
          in
          ''
            ${removeRule "bluetooth"}

            ${removeRule "sound"}
          '';

        systemd.user.services.playerctld = {
          description = "MPRIS media player daemon";

          wantedBy = [ "default.target" ];

          serviceConfig = {
            ExecStart = lib.getExe' pkgs.playerctl "playerctld";
            Type = "dbus";
            BusName = "org.mpris.MediaPlayer2.playerctld";
          };
        };

        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          pulse.enable = true;
          extraConfig.pipewire = {
            "99-custom" = {
              "context.properties" = {
                "module.x11.bell" = false;
                "default.clock.rate" = 48000;
                "default.clock.quantum" = 1024;
                "default.clock.min-quantum" = 1024;
              };
            };
          };
        };
      }
      # easyeffects
      (lib.mkIf true {
        packages = with pkgs; [
          easyeffects
          at-spi2-core
        ];

        hj.xdg.config.files = lib.mapAttrs' (
          k: v:
          # Assuming only one of either input or output block is defined, having both in same file not seem to be supported by the application since it separates it by folder
          let
            folder = builtins.head (builtins.attrNames v);
          in
          lib.nameValuePair "easyeffects/${folder}/${k}.json" {
            source = (pkgs.formats.json { }).generate "${folder}-${k}.json" v;
          }
        ) (builtins.fromJSON (builtins.readFile ./easyeffects.json));

        systemd.user.services.easyeffects = {
          description = "Easyeffects daemon";
          requires = [ "dbus.service" ];
          after = [ "graphical-session.target" ];
          partOf = [
            "graphical-session.target"
            "pipewire.service"
          ];

          wantedBy = [ "graphical-session.target" ];

          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.easyeffects} --gapplication-service --load-preset defaut";
            ExecStop = "${lib.getExe pkgs.easyeffects} --quit";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      })
    ];
}
