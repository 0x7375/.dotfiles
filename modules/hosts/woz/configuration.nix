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
        inputs.titdb.nixosModules.default
      ];

      services.titdb = {
        enable = true;
        device = "/dev/input/event2";
      };

      nix.settings = {
        cores = 4;
        max-jobs = 1;
      };

      boot.extraModprobeConfig = "options hid_apple swap_fn_leftctrl=1";

      powerManagement.resumeCommands =
        # bash
        ''
          # https://github.com/AsahiLinux/linux/issues/497
          # broken rn..........
          # force usb to disconnect/reconnect
          ${lib.getExe pkgs.unstable.tuxvdmtool} disconnect || true
        '';

      system.stateVersion = "25.11";
    };
}
