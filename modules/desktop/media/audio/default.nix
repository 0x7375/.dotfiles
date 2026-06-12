{
  flake.modules.nixos.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    lib.mkMerge [
      {
        persistUser.directories = [
          ".config/pulse"
          ".local/state/wireplumber"
        ];

        me.desktop.bindings =
          let
            playerctl = lib.getExe pkgs.playerctl;
          in
          {
            XF86AudioRaiseVolume = "noctalia msg volume-up";
            XF86AudioLowerVolume = "noctalia msg volume-down";
            XF86AudioMute = "noctalia msg volume-mute";
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
          unstable.pear-desktop
        ];

        services.udev.extraRules = # bash
          let
            removeRule = subsystem: ''
              ACTION=="remove", \
              SUBSYSTEM=="${subsystem}", \
              ENV{WAYLAND_DISPLAY}="wayland-1", \
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
            ExecStart = "${lib.getExe pkgs.easyeffects} --gapplication-service --load-preset default";
            ExecStop = "${lib.getExe pkgs.easyeffects} --quit";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      })
    ];
}
