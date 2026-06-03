{
  flake.modules.nixos.wayland =
    {
      lib,
      pkgs,
      ...
    }:
    {
      me.desktop.startup.kanshi = {
        cmd = "systemctl restart --user ${lib.getExe pkgs.kanshi}";
        always = true;
      };

      packages = [ pkgs.kanshi ];

      systemd.user.services.kanshi = {
        description = "kanshi";
        wantedBy = [ "mango-session.target" ];
        partOf = [ "mango-session.target" ];
        after = [ "mango-session.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.kanshi}";
          Restart = "always";
          RestartSec = 3;
        };
      };

      vars = {
        NIXOS_OZONE_WL = "1";
        GDK_BACKEND = "wayland,x11";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };
}
