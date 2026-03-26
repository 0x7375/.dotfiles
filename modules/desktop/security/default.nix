{
  flake.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    {
      systemd.user.services.polkit-gnome = {
        description = "GNOME PolicyKit Agent";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        wantedBy = [ "graphical-session.target" ];

        serviceConfig.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      };

      packages = with pkgs; [
        polkit_gnome
      ];

      xdg.desktopEntries.bitwarden = {
        exec = "${lib.getExe pkgs.helium} --app=http://vault.bitwarden.com";
        name = "Bitwarden";
        type = "Application";
      };

      me.desktop =
        let
          type = "class";
          name = "vault.bitwarden.com";
        in
        {
          assign = [
            {
              inherit name type;
              workspace = "2";
            }
          ];
          floating = [
            {
              inherit name type;
              enable = false;
            }
          ];
        };
    };
}
