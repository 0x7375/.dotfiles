{
  pkgs,
  myLib,
  system,
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ ] ++ (myLib.filesIn ./default) ++ (myLib.filesIn ./bundles);

  config = lib.mkIf config.me.gui.enable {
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          librewolf
        '';
        mode = "0755";
      };
    };

    environment.systemPackages =
      with pkgs;
      [
        auto.localsend
        via
        gnome-themes-extra
        wireshark
      ]
      ++ [
        inputs.gns3.legacyPackages.${system}.gns3-gui
      ];
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];

    services.gns3-server = {
      enable = true;
      package = inputs.gns3.legacyPackages.${system}.gns3-server;
    };

    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [ pkgs.via ];

    hardware.i2c.enable = true;

    services.input-remapper.enable = true;
    systemd.services.input-remapper.serviceConfig = {
      Environment = "GTK_THEME=Adwaita-dark";
    };

    services.pipewire = {
      enable = true;
      extraConfig.client = {
        "99-disable-bell" = {
          "context.properties" = {
            "module.x11.bell" = false;
          };
        };
      };
    };

    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          MultiProfile = "multiple";
          Privacy = "device";
          FastConnectable = true;
          Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
          # Uncomment on first connection airpods
          # ControllerMode = "bredr";
        };
      };
    };

    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs.adb.enable = true;
    users.users.${config.me.user}.extraGroups = [ "adbusers" ];
  };
}
