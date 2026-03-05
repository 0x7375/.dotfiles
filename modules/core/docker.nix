{
  mkNixos,
  pkgs,
  ...
}:

mkNixos {
  virtualisation.docker.enable = true;
  packages = [ pkgs.docker-compose ];
}
