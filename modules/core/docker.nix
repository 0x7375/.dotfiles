{
  mkNixos,
  pkgs,
  ...
}:

mkNixos {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  packages = [ pkgs.docker-compose ];
}
