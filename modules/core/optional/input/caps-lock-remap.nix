{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.me.capsLockRemap.enable {
  environment.etc."dual-function-keys.yaml".text = ''
    MAPPINGS:
      - KEY: KEY_CAPSLOCK
        TAP: KEY_ESC
        HOLD: KEY_LEFTCTRL
  '';
  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];
    udevmonConfig = ''
      - JOB: "${lib.getExe' pkgs.interception-tools "intercept"} -g $DEVNODE | ${lib.getExe' pkgs.interception-tools-plugins.dual-function-keys "dual-function-keys"} -c /etc/dual-function-keys.yaml | ${lib.getExe' pkgs.interception-tools "uinput"} -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };
}
