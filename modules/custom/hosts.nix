{
  flake.modules.generic.custom =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.me;
      inherit (lib) mkOption types;

      mkNullOption =
        description:
        mkOption {
          type = types.nullOr types.str;
          default = null;
          inherit description;
        };

      sk = {
        main = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKtQ/n+Lg+BZdaGKAkJNykyf93bjvr++lCnEeHQuV6oTAAAABHNzaDo= yubikey-main";
        backup = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTDz1++tiT0SytsEP3XzTshTI6Edd+o6nMTVl/iLxzSAAAABHNzaDo= yubikey-backup";
      };

      hostSubmodule = {
        options = {
          sshPublicKeys = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "SSH public keys";
          };

          sshSigning = {
            key = mkOption {
              type = types.str;
              default = sk.main;
              description = "Public key used for git signing";
            };
            path = mkOption {
              type = types.str;
              default = "sk_main";
              description = "Relative private key path used for ssh agent";
            };
          };

          sopsDecryptionKey = mkOption {
            type = types.str;
            default = cfg.host.sshSigning.path;
            description = "Relative privaty key path used for sops age decryption";
          };

          syncthing = {
            id = mkNullOption "Syncthing Device ID";
            cert = mkNullOption "Syncthing Device certificate";
          };

          kdeconnect = {
            id = mkNullOption "Kdeconnect Device ID";
            cert = mkNullOption "Kdeconnect Device certificate";
            type = lib.mkOption {
              default = "desktop";
              type = lib.types.enum [
                "desktop"
                "phone"
              ];
            };
          };

          ips = {
            lan = mkNullOption "Local Network IP";
            vpn = mkNullOption "Wireguard/VPN IP";
          };
        };
      };
    in
    {
      options.me = {
        hosts = mkOption {
          description = "Central infrastructure definition";
          internal = true;
          type = types.attrsOf (types.submodule hostSubmodule);
          default = {
            yubikey = {
              sshPublicKeys = [
                sk.backup
                sk.main
              ];
            };

            cray = {
              sshSigning = {
                key = sk.backup;
                path = "sk_backup";
              };
              syncthing = {
                id = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
                cert = "MIICHTCCAaOgAwIBAgIJAL9Q1/+3qvuJMAoGCCqGSM49BAMCMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzAeFw0yNDA3MTkwMDAwMDBaFw00NDA3MTQwMDAwMDBaMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzB2MBAGByqGSM49AgEGBSuBBAAiA2IABO2oK2ZKP3lp/PDySB7Sbsr4frvu9f4CB9tXoUXEThdCyxYmrwRuRtOic/l64G0UOEL9wDnNDqCb11HCGabDn/mxLtGMOYAWz8yy5CWOGTKTFzurM6gBqchJDNwpy9WLY6NVMFMwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMBQGA1UdEQQNMAuCCXN5bmN0aGluZzAKBggqhkjOPQQDAgNoADBlAjEAoZ3tD3CmeNqgfog1ksAlwrDtJG8afYxUqplmQoDjRRQOqJOCeMGqHX/BQwqrqdINAjAGmndmDmvLPMg97ZTByiZQbO+9Y0wQ98mAjaAn+2RfZQbPE2X2O+ZQkTMH2daJgOE=";
              };
              kdeconnect = {
                id = "b1542067c7c142e8bb4f52f339be1fab";
                cert = "MIIBnzCCAUSgAwIBAgIULCR5CuRji05l7AMNnGFUkOhP/mgwCgYIKoZIzj0EAwQwTzEpMCcGA1UEAwwgYjE1NDIwNjdjN2MxNDJlOGJiNGY1MmYzMzliZTFmYWIxDDAKBgNVBAoMA0tERTEUMBIGA1UECwwLS0RFIENvbm5lY3QwHhcNMjUwNDE2MTUzMTAwWhcNMzYwNDEzMTUzMTAwWjBPMSkwJwYDVQQDDCBiMTU0MjA2N2M3YzE0MmU4YmI0ZjUyZjMzOWJlMWZhYjEMMAoGA1UECgwDS0RFMRQwEgYDVQQLDAtLREUgQ29ubmVjdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABLaSqp9tAVXXNpqo/W+YbWRF8RL2d+qvk15VNR7MnYQB8gmHoSDwQwWCxSGJcJwEjlCnogyZ5vKSb3ShLevrzdIwCgYIKoZIzj0EAwQDSQAwRgIhAOAP84OWfTZjbJyNJ/eWiJWuW7HSP3X36Eiy94okiaw1AiEAh9ZAq/SS30HukGVNyBhTEaC99vkge/K9Z5s06fzWjv0=";
              };
              ips = {
                lan = "192.168.1.120";
                vpn = "10.0.0.7";
              };
            };

            naitoh = {
              kdeconnect = {
                id = "407c76058f364c7784349f5e0b89b7ad";
                cert = "MIIBnzCCAUWgAwIBAgIVAO82Pup8ShnEwmzUnjSebCWpWDZvMAoGCCqGSM49BAMEME8xKTAnBgNVBAMMIDQwN2M3NjA1OGYzNjRjNzc4NDM0OWY1ZTBiODliN2FkMQwwCgYDVQQKDANLREUxFDASBgNVBAsMC0tERSBDb25uZWN0MB4XDTI1MDQxNjE1MzEyM1oXDTM2MDQxMzE1MzEyM1owTzEpMCcGA1UEAwwgNDA3Yzc2MDU4ZjM2NGM3Nzg0MzQ5ZjVlMGI4OWI3YWQxDDAKBgNVBAoMA0tERTEUMBIGA1UECwwLS0RFIENvbm5lY3QwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAASq/zbPsNmt4X2RBynnkw+s1gFEqvFc3T0pnl2pRmOiED0cQ5o6g3JguOJmgFfQcIMAyTKMuONVvQIesxrY3T9GMAoGCCqGSM49BAMEA0gAMEUCIGyHDPWV0fOkXLh1xI9o0sR6FsyIpCM/16UlCoZ+D1W3AiEAkqr+SvPBJ9T7RwE9tAOgwQxHf1ZhM8PJW5X0fCr1zCo=";
              };
              syncthing = {
                id = "VQTBWUL-XN5DIYJ-2FVH2L5-METP43G-QGVR6HG-4E5TGBC-3G6MUN4-EEUHGQB";
                cert = "MIICHjCCAaOgAwIBAgIJAJgrXGn+qBU+MAoGCCqGSM49BAMCMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzAeFw0yNTAxMDQwMDAwMDBaFw00NDEyMzAwMDAwMDBaMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzB2MBAGByqGSM49AgEGBSuBBAAiA2IABJm5H+bEJGMH1/eLym11KVs43njjVS1BQvTGjsd+6wXzYjZ1Sy04xBJI75vsQHYzLQc464KR7Pu9kLeF2YDVBYn79YsIRmnFa09eBbzvrdWSTYvks0vE2Kli743NhMRGsKNVMFMwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMBQGA1UdEQQNMAuCCXN5bmN0aGluZzAKBggqhkjOPQQDAgNpADBmAjEA8GDJ9q6A1kmqH85D+XjdwdJKoq7tb/2/ijkKupNIqYmDuBnI1jjtvgNaPpd0eW6bAjEA9gCvCAAMHNVIazuEDNvsuU5IvU2R5l26gAi/hzUc0Ngr6fiN1QsPVHLqbOnFt+Xt";
              };
              ips = {
                lan = "192.168.1.198";
                vpn = "10.0.0.2";
              };
            };

            cutler.syncthing.id = "XAFE3W3-FG4XVNB-GCPR4CU-XAYED7H-AISJHBI-JREWBFT-CLUTRPZ-EVYV5AH";

            julliard.sshPublicKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ julliard"
            ];

            pearlman = {
              syncthing = {
                id = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
                cert = "MIICHTCCAaOgAwIBAgIJAJ8i1BFHspdTMAoGCCqGSM49BAMCMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzAeFw0yNDA3MjAwMDAwMDBaFw00NDA3MTUwMDAwMDBaMEoxEjAQBgNVBAoTCVN5bmN0aGluZzEgMB4GA1UECxMXQXV0b21hdGljYWxseSBHZW5lcmF0ZWQxEjAQBgNVBAMTCXN5bmN0aGluZzB2MBAGByqGSM49AgEGBSuBBAAiA2IABOs1h24SG6BSQKrxPGwyl9hNIn0uF2BI60opj7jIP8Li0dPLusGyWfIodKlUskhqE4dc6bOuIdK/RVHmqEwt+cdHKWyUQRr4IZSvOZaEhfn2m1RgtzVcCeZEGeYL9rLwpaNVMFMwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMBQGA1UdEQQNMAuCCXN5bmN0aGluZzAKBggqhkjOPQQDAgNoADBlAjEA14v+C1RkCQteaf/BqYKd/X3Ut+iuCzeU2JPeV8y7B2fQpbc5wU6eJi7d721ZWCZaAjAZHQZRvoOv70/VdgjuTwjb6WRHiGCmiv0btujEjPjlLPkcuyXOCb+Nunyfj+BHLto=";
              };
              ips = {
                lan = "192.168.1.82";
                vpn = "10.0.0.1";
              };
            };

            mach =
              let
                pub = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDIZOAfbe03pFpRXeB5ll3wNv+rZNgZg4rtCoiNELf3JJ7m54ze7QUrsy8LgIVk08r+Q8tuwA16yA+oDpK9fuys= mach";
              in
              {
                kdeconnect = {
                  id = "cb388b0a4fde4635a5334002cb2d90d0";
                  cert = "MIIBnzCCAUSgAwIBAgIUO9REDL3IKkJExYu1MSV+ySB3OCEwCgYIKoZIzj0EAwQwTzEpMCcGA1UEAwwgY2IzODhiMGE0ZmRlNDYzNWE1MzM0MDAyY2IyZDkwZDAxDDAKBgNVBAoMA0tERTEUMBIGA1UECwwLS0RFIENvbm5lY3QwHhcNMjUwMjAzMTc1NzQyWhcNMzYwMjAxMTc1NzQyWjBPMSkwJwYDVQQDDCBjYjM4OGIwYTRmZGU0NjM1YTUzMzQwMDJjYjJkOTBkMDEMMAoGA1UECgwDS0RFMRQwEgYDVQQLDAtLREUgQ29ubmVjdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABIxwmZc1Tnu4Ow/oQUyaSU7/ii1Z8e8oSS1I9bpG6nCVhcwI4MV4etjQoOz574DkbVJ8DVG55bhzcYy1Gv1SJkEwCgYIKoZIzj0EAwQDSQAwRgIhAMeVOD2erjIyrjR/SjIekyor+8QDivshQBKn8V0z6CjBAiEAlrGs0msOI7DV0yBY+QOKeqgFJJv/8ANSOZUYHvK+/GA=";
                };
                syncthing = {
                  id = "32SVOZP-RJL755K-D7ZTMRL-7FOTZZF-V7W5V5J-2JOIMCG-W6MRDGK-AO4D4AC";
                  cert = "MIIBoDCCAVKgAwIBAgIJAPA5JeoDFWwfMAUGAytlcDBKMRIwEAYDVQQKEwlTeW5jdGhpbmcxIDAeBgNVBAsTF0F1dG9tYXRpY2FsbHkgR2VuZXJhdGVkMRIwEAYDVQQDEwlzeW5jdGhpbmcwHhcNMjYwMTEzMDAwMDAwWhcNNDYwMTA4MDAwMDAwWjBKMRIwEAYDVQQKEwlTeW5jdGhpbmcxIDAeBgNVBAsTF0F1dG9tYXRpY2FsbHkgR2VuZXJhdGVkMRIwEAYDVQQDEwlzeW5jdGhpbmcwKjAFBgMrZXADIQB4nrrv2Rlh6KN+QAuS/9buTkkT+IZtQ7m0Q3uPRoTUmqNVMFMwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMBQGA1UdEQQNMAuCCXN5bmN0aGluZzAFBgMrZXADQQCRPrVuQaWNo5UwYhnk2tTIK6vMgM7kcZXY77hGEOLjsXaQw1JhR+yQjpLk7vEKB1rbLNcnrPq3dVDjDC/RscMG";
                };
                sshSigning.key = pub;
                sshPublicKeys = [ pub ];
                ips = {
                  lan = "192.168.1.168";
                  vpn = "10.0.0.5";
                };
              };

            shannon = {
              kdeconnect = {
                id = "c36b03ebc1a0475890a4bc4deec367ac";
                cert = "MIIBizCCATGgAwIBAgIBATAKBggqhkjOPQQDBDBPMSkwJwYDVQQDDCBjMzZiMDNlYmMxYTA0NzU4OTBhNGJjNGRlZWMzNjdhYzEUMBIGA1UECwwLS0RFIENvbm5lY3QxDDAKBgNVBAoMA0tERTAeFw0yNTAzMTMyMzAwMDBaFw0zNjAzMTMyMzAwMDBaME8xKTAnBgNVBAMMIGMzNmIwM2ViYzFhMDQ3NTg5MGE0YmM0ZGVlYzM2N2FjMRQwEgYDVQQLDAtLREUgQ29ubmVjdDEMMAoGA1UECgwDS0RFMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEyWx1bS8R7NY9tGjEo19yTuhoPrLC1UOBPJ1ePdxIBGkG3NEOncbqkz7ODCLyKi8oLmtmDfzj1X88brss9UaPEzAKBggqhkjOPQQDBANIADBFAiEA8e1hpOXqH5zJZI/xKDjzYXMsA9LOmXPL10ELkxqGSnwCIBFMI/cfp+9Q2yzBe/4EANm44e86um7OwPTP9Yrmq9WS";
                type = "phone";
              };
              syncthing.id = "NCNYWXS-TGOZLXL-IZHMOQU-WNMNRSP-LDM5MFX-S4S5674-EYTMUAL-JB4WTQI";
              ips.vpn = "10.0.0.3";
            };

            lamarr = {
              syncthing.id = "ZMUWGAS-D7ETM4C-77LZJQD-T3VBPZS-UWXFTVN-K32GD5G-XKCP4UG-OMRG4AA";
              ips.vpn = "10.0.0.4";
            };

            yoshino = {
              syncthing.id = "4J5QS3L-TBUVQNM-RID2OP7-RTQG4GA-NWRB2E5-HXMTK7R-4C4QBFL-7M3RDAU";
              ips.vpn = "10.0.0.6";
            };
          };
        };

        host = mkOption {
          type = types.submodule hostSubmodule;
          default = cfg.hosts.${cfg.hostname} or { };
          internal = true;
        };
      };
    };
}
