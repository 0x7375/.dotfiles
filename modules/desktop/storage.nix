{ self, ... }:
let
  mkKdeConnectConfig =
    { config, lib }:
    let
      inherit (config.me) hostname;
      kdeconnectHosts = lib.filterAttrs (
        n: h: n != hostname && h.kdeconnect.id != null && h.kdeconnect.cert != null
      ) config.me.hosts;
    in
    {
      "config".text = # ini
        ''
          [General]
          keyAlgorithm=EC
          name=${hostname}
        '';

      "certificate.pem".text = ''
        -----BEGIN CERTIFICATE-----
        ${config.me.host.kdeconnect.cert}
        -----END CERTIFICATE-----
      '';

      "trusted_devices".text = lib.concatMapAttrsStringSep "\n" (
        name: _:
        let
          h = config.me.hosts.${name};
        in
        ''
          [${h.kdeconnect.id}]
          certificate="-----BEGIN CERTIFICATE-----\n${h.kdeconnect.cert}\n-----END CERTIFICATE-----\n"
          name=${name}
          protocolVersion=8
          type=${h.kdeconnect.type}
        ''
      ) kdeconnectHosts;
    };
in
{
  flake.shared.desktop =
    { config, ... }:
    {
      me.hostSecrets."kdeconnect/key".owner = config.me.user;
    };

  flake.nixos.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      packages = with pkgs; [
        nemo
        ntfs3g
        exfat
        xarchiver
      ];

      programs.kdeconnect.enable = true;
      me.desktop.startup.kdeconnect = lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";

      me.hostSecrets."kdeconnect/key".path = "${config.me.home}/.config/kdeconnect/privateKey.pem";

      hj.xdg.config.files =
        lib.mapAttrs' (n: v: lib.nameValuePair "kdeconnect/${n}" v)
          (mkKdeConnectConfig {
            inherit config lib;
          });

      xdg.mimeApps.defaultApplications = self.lib.mapMimeEntries [
        "application/bzip2"
        "application/gzip"
        "application/zip"
        "application/vnd.rar"
        "application/x-7z-compressed-tar"
        "application/x-bzip"
        "application/x-bzip2"
        "application/x-bzip2-compressed-tar"
        "application/x-bzip-compressed-tar"
        "application/x-compress"
        "application/x-compressed-tar"
        "application/x-cpio"
        "application/x-lha"
        "application/x-lzip"
        "application/x-lzip-compressed-tar"
        "application/x-lzma"
        "application/x-lzma-compressed-tar"
        "application/x-rar-compressed"
        "application/x-tarz"
        "application/x-xar"
        "application/x-xz"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
        "application/zstd"
      ] "xarchiver";
    };

  flake.darwin.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      kdeconnectDir = "${config.me.home}/Library/Preferences/kdeconnect";
      kdeconnect-nightly = pkgs.stdenv.mkDerivation rec {
        pname = "kdeconnect-nightly";
        version = "5855";
        src = pkgs.fetchurl {
          url = "https://origin.cdn.kde.org/ci-builds/network/kdeconnect-kde/master/macos-arm64/kdeconnect-kde-master-${version}-macos-clang-arm64.dmg";
          hash = "sha256-aCPTooLM9hJ7hZrXzl3jfaQS7xOgXd2L87n/Qs1+YSY=";
        };
        nativeBuildInputs = [ pkgs.undmg ];
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/Applications
          cp -r *.app $out/Applications
        '';
      };
    in
    {
      packages = [ kdeconnect-nightly ];

      me.hostSecrets."kdeconnect/key".path = "${kdeconnectDir}/privateKey.pem";

      hj.files = lib.mapAttrs' (n: v: lib.nameValuePair "${kdeconnectDir}/${n}" v) (mkKdeConnectConfig {
        inherit config lib;
      });
    };
}
