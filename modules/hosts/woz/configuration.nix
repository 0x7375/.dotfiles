{ inputs, ... }:

{
  flake.modules.nixos.woz = {
    nix.settings = {
      extra-substituters = [ "https://nixos-apple-silicon.cachix.org" ];
      extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };

    imports = [
      inputs.apple-silicon.nixosModules.apple-silicon-support
    ];

    boot.extraModprobeConfig = "options hid_apple swap_fn_leftctrl=1";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;

    time.timeZone = "Europe/Paris";

    system.stateVersion = "25.11";
  };
}
