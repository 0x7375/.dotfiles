{
  flake.modules.nixos.naitoh =
    {
      config,
      ...
    }:
    {
      me.services.radarr = {
        subdomain = "movies";
        port = config.nixflix.radarr.config.hostConfig.port;
      };

      me.hostSecrets."radarr/api_key" = { };
      me.hostSecrets."radarr/pw" = { };

      nixflix.recyclarr.config.radarr.radarr = {
        media_naming.movie.rename = true;
        custom_formats =
          let
            allProfiles = [
              { name = "Any"; }
              { name = "HD - 720p/1080p"; }
              { name = "HD-720p"; }
              { name = "HD-1080p"; }
              { name = "Ultra-HD"; }
            ];
          in
          [
            {
              trash_ids = [ "d6e9318c875905d6cfb5bee961afcea9" ]; # Language: Not Original
              assign_scores_to = allProfiles;
            }
          ];
      };

      nixflix.radarr = {
        enable = true;
        openFirewall = true;
        config = {
          mediaManagement.autoUnmonitorPreviouslyDownloadedMovies = true;
          apiKey._secret = config.sops.secrets."radarr/api_key".path;
          hostConfig.password._secret = config.sops.secrets."radarr/pw".path;
        };
      };
    };
}
