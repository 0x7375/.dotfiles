
{ config, ... }:

let
  ports = [ 111 2049 4001 4002 4000 ];
  in
{
  fileSystems."/export/data" = {
    device = "/data";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /export ${config.me.networkIps.lan.subnet}(rw,sync,no_subtree_check,no_root_squash)
      /export/data ${config.me.networkIps.lan.subnet}(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;
}
