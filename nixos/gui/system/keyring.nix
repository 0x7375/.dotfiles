{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  environment.systemPackages = with pkgs; [
    polkit_gnome
    libsecret
    libgnome-keyring
  ];
}
