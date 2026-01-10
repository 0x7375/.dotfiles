let
  ntfyPort = 8719;
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://localhost:" + toString ntfyPort;
      listen-http = ":" + toString ntfyPort;
      auth-default-access = "read-write";
      cache-file = "/var/lib/ntfy-sh/cache.db";
    };
  };
  networking.firewall.allowedTCPPorts = [ ntfyPort ];
}
