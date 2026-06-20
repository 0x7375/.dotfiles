{ inputs, ... }:

{
  flake.modules.nixos.woz =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nix.settings = {
        extra-substituters = [ "https://nixos-apple-silicon.cachix.org" ];
        extra-trusted-public-keys = [
          "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
        ];
      };

      imports = [
        inputs.apple-silicon.nixosModules.apple-silicon-support
      ];

      nix.settings = {
        cores = 4;
        max-jobs = 1;
      };

      boot.extraModprobeConfig = "options hid_apple swap_fn_leftctrl=1";

      powerManagement.resumeCommands =
        # bash
        ''
          # force usb to disconnect/reconnect
          ${lib.getExe pkgs.unstable.tuxvdmtool} disconnect
        '';

      tinted.files.".config/mango/config.conf".value.trackpad_scroll_factor = 0.3;

      system.stateVersion = "25.11";
    };
}
