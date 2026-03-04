{
  lib,
  config,
  mkNixos,
  pkgs,
  ...
}:

let
  inherit (config.me) user hostname;
  mkHostSecret = lib.my.mkHostSecret hostname;
in
lib.mkIf config.me.wm.enable (mkNixos {
  packages = with pkgs; [
    nemo
    ntfs3g
    exfat
  ];

  programs.kdeconnect.enable = true;
  me.wm.startup.kdeconnect = lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-indicator";

  sops.secrets."kdeconnect/key" = mkHostSecret "kdeconnect/key" {
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
})
