{ lib, config, ... }:

lib.mkIf config.me.network.enable {
  networking.extraHosts = ''
    192.168.1.198 ryusei ryusei.local
    192.168.1.120 yugen yugen.local
    192.168.1.95 hikari hikari.local
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;
  users.users.${config.me.user}.extraGroups = [ "networkmanager" ];

  networking.firewall.enable = true;
}
