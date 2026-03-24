{
  flake.nixos.naitoh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      networking.firewall.allowedUDPPorts = [ 25565 ];
      networking.firewall.allowedTCPPorts = [ 25565 ];

      # users.users.${user} = {
      #   extraGroups = [ "minecraft" ];
      # };

      packages = with pkgs; [
        git
        git-lfs
      ];

      services.minecraft-server = {
        enable = true;
        eula = true;
        jvmOpts = "-Xmx8192M -Xms8192M";
        declarative = true;
        serverProperties = {
          difficulty = "hard";
          gamemode = "survival";
          max-players = 3;
          motd = "${config.me.user}'s server";
          pvp = true;
          server-port = 25565;
          simulation-distance = 24;
          view-distance = 24;
          white-list = false;
        };
      };

      systemd.services.minecraft-server.wantedBy = lib.mkForce [ ];
    };
}
