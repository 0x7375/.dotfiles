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

  yubikey-main = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKtQ/n+Lg+BZdaGKAkJNykyf93bjvr++lCnEeHQuV6oTAAAABHNzaDo= yubikey-main";
  yubikey-backup = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTDz1++tiT0SytsEP3XzTshTI6Edd+o6nMTVl/iLxzSAAAABHNzaDo= yubikey-backup";

  hostSubmodule = {
    options = {
      sshPublicKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "SSH public keys";
      };

      sshSigningKey = mkOption {
        type = types.str;
        default = yubikey-main;
        description = "Public key used for git signing";
      };

      syncthingId = mkNullOption "Syncthing Device ID";
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
            yubikey-backup
            yubikey-main
          ];
        };

        cray = {
          sshSigningKey = yubikey-backup;
          syncthingId = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
          ips.lan = "192.168.1.120";
        };

        naitoh = {
          syncthingId = "VQTBWUL-XN5DIYJ-2FVH2L5-METP43G-QGVR6HG-4E5TGBC-3G6MUN4-EEUHGQB";
          ips = {
            lan = "192.168.1.198";
            vpn = "10.0.0.2";
          };
        };

        cutler.syncthingId = "XAFE3W3-FG4XVNB-GCPR4CU-XAYED7H-AISJHBI-JREWBFT-CLUTRPZ-EVYV5AH";

        julliard.sshPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ julliard"
        ];

        wilson = {
          syncthingId = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
          ips = {
            lan = "192.168.1.95";
            vpn = "10.0.0.1";
          };
        };

        mach =
          let
            pub = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLePZnDLZNnXzR5vgtmdu+fDEKu3GH87jM2EjSyBIF/0fEL8WPf9MkWRTsa3CY8bf+1SlFqUiGrtrMzyDx4fnPg=";
          in
          {
            syncthingId = "32SVOZP-RJL755K-D7ZTMRL-7FOTZZF-V7W5V5J-2JOIMCG-W6MRDGK-AO4D4AC";
            sshSigningKey = pub;
            sshPublicKeys = [ pub ];
            ips = {
              lan = "192.168.1.168";
              vpn = "10.0.0.5";
            };
          };

        shannon = {
          syncthingId = "JJ62FKA-U5HTR5S-NJ7A4EJ-TMO66SZ-QNUOYUA-CCQMUIB-STDX4RE-VCGEKAB";
          ips.vpn = "10.0.0.3";
        };

        lamarr = {
          syncthingId = "ZMUWGAS-D7ETM4C-77LZJQD-T3VBPZS-UWXFTVN-K32GD5G-XKCP4UG-OMRG4AA";
          ips.vpn = "10.0.0.4";
        };

        yoshino = {
          syncthingId = "4J5QS3L-TBUVQNM-RID2OP7-RTQG4GA-NWRB2E5-HXMTK7R-4C4QBFL-7M3RDAU";
          ips.vpn = "10.0.0.6";
        };
      };
    };

    host = mkOption {
      type = types.submodule hostSubmodule;
      default = cfg.hosts.${cfg.hostname};
      internal = true;
    };
  };
}
