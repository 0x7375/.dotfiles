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

  hj.xdg.config.files."kdeconnect/config".text = # ini
    ''
      [General]
      disabled_providers=@Invalid()
      name=${config.me.hostname}
    '';

  sops.secrets."kdeconnect/cert" = mkHostSecret "kdeconnect/cert" {
    owner = user;
    path = "~/.config/kdeconnect/certificate.pem";
  };
  sops.secrets."kdeconnect/key" = mkHostSecret "kdeconnect/key" {
    owner = user;
    path = "~/.config/kdeconnect/key.pem";
  };

})
