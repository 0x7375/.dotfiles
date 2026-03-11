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
            id = "9c083e1d_bb07_4c99_af92_c12a2029bf3d";
            cert = "MIIDVzCCAj+gAwIBAgIBCjANBgkqhkiG9w0BAQsFADBVMS8wLQYDVQQDDCZfOWMw\nODNlMWRfYmIwN180Yzk5X2FmOTJfYzEyYTIwMjliZjNkXzEMMAoGA1UECgwDS0RF\nMRQwEgYDVQQLDAtLZGUgY29ubmVjdDAeFw0yNDA2MDYwODAyMTRaFw0zNDA2MDYw\nODAyMTRaMFUxLzAtBgNVBAMMJl85YzA4M2UxZF9iYjA3XzRjOTlfYWY5Ml9jMTJh\nMjAyOWJmM2RfMQwwCgYDVQQKDANLREUxFDASBgNVBAsMC0tkZSBjb25uZWN0MIIB\nIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyD4kV++sqmWn+vt8HRjveXS9\n/9rj+2bS8jDscyPcoe5REFJZeaBnslZa1/xqip+6US/uEd7z1MN6ozTsS1ecmKym\nCMRA10gD/fed2g8YA/dwRamqf6X9y/dUmUmVIyccSxfObOScnoNs1yLBFhWbLiiP\ntbi2ejhW2FopElHCGBegNEN5Nr6/vtpxH6lt3QxfcFKe7T7BmxEe7XggGzA5vVd2\ntNHDWx2OLRKL+U4T1wIHAtSuGFepwV9Q803J05R8sSz29atc344n2L8XsKcC0XHa\nbHQWYlQ9tIw5Zl3Bb/Rfhhy9FrOY/bXc4jVz5ZWqsa354oGJaBWM5bnve1btawID\nAQABozIwMDAdBgNVHQ4EFgQUrFnPlQl3s0E0FtyZz8I3ORpdoVswDwYDVR0TAQH/\nBAUwAwIBADANBgkqhkiG9w0BAQsFAAOCAQEAPxrR5cNXC78JLzPrTSRr8H5DhWQw\n0Nio+x45pBfxPOFUSCKKZGDra4NQVpvdFWmxQzx2vMxmApnYMSj7uuHD7ic1IKRv\nNLyHGQly7ALvP4KdoQykQzXKbwQkwZ+TOyswyMLMQ5RGPdiW5a/XOxhMiwTrMqz2\n72WL0RN0MhbUiddi7YYdxRr6Y5VPBsnlhenh9Mla/JokALTZT/JiGLITWr8qspX9\nRW3x7NrVzpbOMOMSkx1/47WMNq+BPJggoSOsCsmk1vnUcJ3YPxfiR9nLZR6dtK/5\nAONkcSka1HzCEPipLofJML6qau9V/PGLMe98EyGW9Y3PfRVsXAESasJL0A==";
          };
          ips = {
            lan = "192.168.1.120";
            vpn = "10.0.0.7";
          };
        };

        naitoh = {
          kdeconnect = {
            id = "78d615df_0689_420d_a32a_da64b5856f71";
            cert = "MIIDVzCCAj+gAwIBAgIBCjANBgkqhkiG9w0BAQsFADBVMS8wLQYDVQQDDCZfNzhkNjE1ZGZfMDY4OV80MjBkX2EzMmFfZGE2NGI1ODU2ZjcxXzEMMAoGA1UECgwDS0RFMRQwEgYDVQQLDAtLZGUgY29ubmVjdDAeFw0yNDA2MDQxMTU3MjBaFw0zNDA2MDQxMTU3MjBaMFUxLzAtBgNVBAMMJl83OGQ2MTVkZl8wNjg5XzQyMGRfYTMyYV9kYTY0YjU4NTZmNzFfMQwwCgYDVQQKDANLREUxFDASBgNVBAsMC0tkZSBjb25uZWN0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkFTsVy79pn5FrypJ3FWbZRGBxaUHyD/Z/ptH+Ar4U60o3rzdS/7fTV6y0r4YYyY46P2YqDF1xxmn9wIJ1KcIPXbQIVYxP8DUncd4cau98ybOaaayF9j4BtP6psVwcrOFRbn2ZGPClZ68aoxAuvAX6MR/36WhBwZKho5qRukpyfxveREeB7zqYBqohj86eC8UEoebC3LDogqXTnQT13QhXZERwjTOyFx2SH9XGHHcBcGmv+XLQt+qcBOBibmLoXR5dIhc5JJyVT7gsyp/76c92n49oT9gmvzWxIW85mwz4mD0E7SwSSjxVx9DuuHcaY9DmP6EIqx4DozsgpXdIZcfFwIDAQABozIwMDAdBgNVHQ4EFgQUyXvey6CbLhEr707hfnUCEabJtaUwDwYDVR0TAQH/BAUwAwIBADANBgkqhkiG9w0BAQsFAAOCAQEAc3xT6q4vY3Y3t+V3jj4y08XV7CoPuTJfZ0sJ2Ea8xNS42pq1KaiyVP0ID4NU1WkWnEUUyfNI3UgRNHyqmCleuT+IAp0qB6rUk9xF2hpyaKpiRmkAh2hvh3x4AoClw2vskI3p1cueG7og3CcnTV0BO1uO5WTvLg4FkdKcEwi+4aIg3kC80H97gLZxPX2w4Xxb+bJ9vd7MY9vJoRLu3a++YtKOvHDwmusHq3yakAVO15dLHn0YF8d5p9950ISLVBcjC6BbKkTEy2HObJ3pF9SSUFvDq8Ld4J86OCaQJu6xFCqcsdWELSvtV045/kkJAxPuDMDNNHc+pMu9Z2nYQtwQcA==";
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
            pub = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLePZnDLZNnXzR5vgtmdu+fDEKu3GH87jM2EjSyBIF/0fEL8WPf9MkWRTsa3CY8bf+1SlFqUiGrtrMzyDx4fnPg=";
          in
          {
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
          syncthing.id = "JJ62FKA-U5HTR5S-NJ7A4EJ-TMO66SZ-QNUOYUA-CCQMUIB-STDX4RE-VCGEKAB";
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
}
