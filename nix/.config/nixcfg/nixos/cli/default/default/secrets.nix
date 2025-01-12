{
  secrets,
  config,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  age.identityPaths = [
    "/home/${config.me.user}/.ssh/agenix"
  ];

  age.secrets.laptop-vpn-psk = {
    file = "${secrets}/laptop-vpn-psk.age";
    owner = config.me.user;
  };
}
