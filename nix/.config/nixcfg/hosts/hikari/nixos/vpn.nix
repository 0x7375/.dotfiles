{
  lib,
  secrets,
  pkgs,
  config,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."hikari/protonvpn_pk" = { };

  services.protonvpn = {
    enable = true;

    interface = {
      privateKeyFile = config.sops.secrets."hikari/protonvpn_pk".path;
    };

    endpoint = {
      publicKey = "wYsaKyJteQ1gYoJZAZT0FettXDOidPhQZwl0DhaabF0=";
      ip = "redacted";
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  sops.secrets."hikari/server_vpn_pk" = {
    owner = config.me.user;
  };

  sops.secrets.laptop_vpn_psk = {
    owner = config.me.user;
  };

  sops.secrets.phone_vpn_psk = {
    owner = config.me.user;
  };

  networking.firewall.allowedUDPPorts = [ 51821 ];

  networking.wg-quick.interfaces.homevpn = {
    address = [ "10.0.0.1/24" ];
    listenPort = 51821;
    privateKeyFile = config.sops.secrets."hikari/server_vpn_pk".path;

    peers = [
      # laptop
      {
        publicKey = "apB8TVyEJ7G/gLe5b3ckvUYJSSKv85rl1jWkZoiEQgE=";
        presharedKeyFile = config.sops.secrets.laptop_vpn_psk.path;
        allowedIPs = [ "10.0.0.2/32" ];
      }
      # phone
      {
        publicKey = "mEN17hfodGLbe58cS6r7qeegmeQlSebz2JCUIlsWdn0=";
        presharedKeyFile = config.sops.secrets.phone_vpn_psk.path;
        allowedIPs = [ "10.0.0.3/32" ];
      }
    ];
  };
}
