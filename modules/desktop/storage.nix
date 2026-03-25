{ self, ... }:

{
  flake.nixos.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.me) user hostname;
    in
    {
      packages = with pkgs; [
        nemo
        ntfs3g
        exfat
        xarchiver
      ];

      programs.kdeconnect.enable = true;
      me.desktop.startup.kdeconnect = lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";

      me.hostSecrets."kdeconnect/key" = {
        owner = user;
        path = "${config.me.home}/.config/kdeconnect/privateKey.pem";
      };

      hj.xdg.config.files."kdeconnect/config".text = # ini
        ''
          [General]
          disabled_providers=@Invalid()
          name=${config.me.hostname}
        '';

      hj.xdg.config.files."kdeconnect/certificate.pem".text = ''
        -----BEGIN CERTIFICATE-----
        ${config.me.host.kdeconnect.cert}
        -----END CERTIFICATE-----
      '';

      hj.xdg.config.files."kdeconnect/trusted_devices".text =
        let
          kdeconnectHosts = lib.filterAttrs (
            n: h: n != hostname && h.kdeconnect.id != null && h.kdeconnect.cert != null
          ) config.me.hosts;
        in
        lib.concatMapAttrsStringSep "\n" (
          name: _:
          let
            h = config.me.hosts.${name};
          in
          ''
            [_${h.kdeconnect.id}_]
            certificate="-----BEGIN CERTIFICATE-----\n${h.kdeconnect.cert}\n-----END CERTIFICATE-----\n"
            name=${name}
            protocolVersion=8
            type=desktop

          ''
        ) kdeconnectHosts;

      xdg.mimeApps.defaultApplications = self.lib.mimeMapEntries [
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
}
