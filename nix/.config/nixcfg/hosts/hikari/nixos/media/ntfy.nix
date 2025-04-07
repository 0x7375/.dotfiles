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

    };
  };
  networking.firewall.allowedTCPPorts = [ ntfyPort ];
}
