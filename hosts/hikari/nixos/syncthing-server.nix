{
  lib,
  config,
  myLib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  networking.firewall.allowedTCPPorts = [ 8384 ];

  sops.secrets."hikari/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."hikari/syncthing/key" = {
    owner = config.me.user;
  };

  systemd.services = myLib.notifyOnServiceFailure "syncthing";

  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    key = "${config.sops.secrets."hikari/syncthing/key".path}";
    cert = "${config.sops.secrets."hikari/syncthing/cert".path}";
    settings =
      let
        inherit (myLib) syncthingDirConfig;
        mkRo =
          {
            name,
            config,
            ro-devices ? [ "tsuno" ],
          }:
          {
            "${name}" = syncthingDirConfig config;
            "${name}-ro" = syncthingDirConfig (
              config
              // {
                type = "sendonly";
                devices = ro-devices;
              }
            );
          };
      in
      {
        devices = {
          "neiro" = {
            id = "JJ62FKA-U5HTR5S-NJ7A4EJ-TMO66SZ-QNUOYUA-CCQMUIB-STDX4RE-VCGEKAB";
          };
          "yugen" = {
            id = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
          };
          "ryusei" = {
            id = "VQTBWUL-XN5DIYJ-2FVH2L5-METP43G-QGVR6HG-4E5TGBC-3G6MUN4-EEUHGQB";
          };
          "tsuno" = {
            id = "XAFE3W3-FG4XVNB-GCPR4CU-XAYED7H-AISJHBI-JREWBFT-CLUTRPZ-EVYV5AH";
          };
        };
        folders =
          {
            ds = syncthingDirConfig {
              path = "games/ds";
              devices = [
                "yugen"
                "ryusei"
                "tsuno"
              ];
            };
            switch = syncthingDirConfig {
              path = "games/switch";
              devices = [
                "yugen"
                "ryusei"
                "tsuno"
              ];
            };
            ryujinx = syncthingDirConfig {
              path = "ryujinx";
              devices = [
                "yugen"
                "ryusei"
                "tsuno"
              ];
            };
            gamecube = syncthingDirConfig {
              path = "games/gamecube";
              devices = [
                "yugen"
                "ryusei"
                "tsuno"
              ];
            };
            dolphin = syncthingDirConfig {
              path = "dolphin";
              devices = [
                "yugen"
                "ryusei"
                "tsuno"
              ];
            };
            perso = syncthingDirConfig {
              path = "perso";
              devices = [
                "yugen"
                "ryusei"
              ];
            };
            universite = syncthingDirConfig {
              path = "documents/pdf/universite";
              devices = [
                "neiro"
              ];
            };
            windows = syncthingDirConfig {
              path = "windows";
              devices = [
                "tsuno"
                "ryusei"
                "yugen"
              ];
            };
            courses = syncthingDirConfig {
              path = "courses";
              devices = [
                "tsuno"
                "ryusei"
                "yugen"
                "neiro"
              ];
            };
          }
          // (mkRo {
            name = "pictures";
            config = {
              path = "pictures";
              devices = [
                "yugen"
                "ryusei"
              ];
            };
          })
          // (mkRo {
            name = "documents";
            config = {
              path = "documents";
              devices = [
                "yugen"
                "ryusei"
              ];
            };
            ro-devices = [
              "tsuno"
              "neiro"
            ];
          })
          // (mkRo {
            name = "notes";
            config = {
              path = "notes";
              devices = [
                "yugen"
                "ryusei"
                "neiro"
              ];
            };
          })
          // (mkRo {
            name = "photos";
            config = {
              path = "photos";
              devices = [
                "yugen"
                "ryusei"
                "neiro"
              ];
            };
          })

          // (mkRo {
            name = "uni";
            config = {
              path = "uni";
              devices = [
                "yugen"
                "ryusei"
              ];
            };
            ro-devices = [
              "tsuno"
            ];
          });
      };
  };
}
