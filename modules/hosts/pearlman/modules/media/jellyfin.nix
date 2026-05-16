{
  flake.modules.nixos.pearlman =
    { pkgs, config, ... }:
    {
      me.services.jellyfin = {
        subdomain = "media";
        port = 8096;
      };

      users.users.jellyfin.extraGroups = [
        "render"
        "video"
      ];

      services.jellyfin = {
        enable = true;
        package = pkgs.auto.jellyfin;
        group = config.me.mediaGroup;
        openFirewall = true;
      };

      packages = with pkgs; [
        auto.jellyfin-web
        auto.jellyfin-ffmpeg
      ];
    };
}
