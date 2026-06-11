{ self, ... }:

{
  flake.modules.generic.network =
    { config, lib, ... }:
    {
      environment.etc.hosts.text =
        let
          hosts = lib.flatten (
            lib.mapAttrsToList (
              h: v:
              (lib.optional (v.ips.lan != null) "${v.ips.lan} ${h}")
              ++ (lib.optional (v.ips.vpn != null) "${v.ips.vpn} ${h}.vpn")
            ) config.me.hosts
          );
        in
        lib.mkForce ''
          127.0.0.1 localhost
          255.255.255.255 broadcasthost
          ::1 localhost
          ${builtins.concatStringsSep "\n" hosts}
          192.168.1.86 hilse
        '';
    };

  flake.modules.darwin.network =
    {
      lib,
      ...
    }:
    {
      preActivation = "rm -f /etc/hosts";

      networking.dns = [
        "127.0.0.1"
        "::1"
      ];

      # https://github.com/cameronraysmith/vanixiets/blob/0f5f3018b628bc287a4b6339553180c696c233dc/modules/darwin/dnscrypt-proxy.nix#L188
      services.dnscrypt-proxy = {
        enable = true;
        settings = {
          listen_addresses = [
            "127.0.0.1:53"
            "[::1]:53"
          ];

          server_names = [
            "quad9-doh-ip4-primary"
            "quad9-doh-ip4-secondary"
          ];

          ipv4_servers = true;
          dnscrypt_servers = false;
          doh_servers = true;

          require_nolog = true;
          require_nofilter = false;

          bootstrap_resolvers = [ ];
          ignore_system_dns = true;
          netprobe_address = "9.9.9.9:443";

          cache = true;
          cache_size = 4096;

          static = {
            "quad9-doh-ip4-primary".stamp = "sdns://AgMAAAAAAAAABzkuOS45LjkADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ";
            "quad9-doh-ip4-secondary".stamp =
              "sdns://AgMAAAAAAAAADzE0OS4xMTIuMTEyLjExMgANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5";
          };
        };
      };

      launchd.daemons.dnscrypt-proxy.serviceConfig = {
        UserName = lib.mkForce "root";
        GroupName = lib.mkForce "wheel";
      };

      users.users._dnscrypt-proxy.home = lib.mkForce "/var/lib/dnscrypt-proxy";

      networking.knownNetworkServices = [
        "Wi-Fi"
        "USB 10/100 LAN"
        "Thunderbolt Bridge"
      ];
    };

  flake.modules.nixos.network =
    { lib, config, ... }:
    {
      persist.directories = [
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
      ];

      imports = [ self.modules.generic.network ];

      networking.nameservers = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "2620:fe::9#dns.quad9.net"
      ];

      services.resolved = {
        enable = true;
        dnsovertls = "true";
        dnssec = "true";
        fallbackDns = [ ];
        domains = [ "~." ];
      };

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
        connectionConfig = {
          "ipv4.ignore-auto-dns" = true;
          "ipv6.ignore-auto-dns" = true;
        };
      };

      networking.wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = false;
          };
        };
      };

      users.users.${config.me.user}.extraGroups = [ "networkmanager" ];

      # don't wait for network on boot
      systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

      networking.nftables.enable = true;
      networking.firewall.enable = true;
    };

  flake.modules.nixos.networkEnvironment =
    {
      config,
      secrets,
      ...
    }:
    {
      imports = [ self.modules.nixos.network ];

      sops.secrets.networkingEnvironment = {
        sopsFile = "${secrets}/networking-environment.env";
        format = "dotenv";
        key = "";
        owner = config.me.user;
      };

      systemd.services.NetworkManager-ensure-profiles = {
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];
      };

      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ config.sops.secrets.networkingEnvironment.path ];
        profiles = {
          home-wifi = {
            connection = {
              id = "home-wifi";
              type = "wifi";
            };
            wifi = {
              ssid = "$SSID_HOME";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$PSK_HOME";
            };
          };
          sekai = {
            connection = {
              id = "sekai";
              type = "wifi";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "sekai";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$PSK_SEKAI";
            };
          };
        };
      };
    };
}
