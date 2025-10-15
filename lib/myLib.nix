{ inputs, ... }:
let
  myLib = (import ./myLib.nix) { inherit inputs; };
  specialArgs = {
    inherit inputs myLib;
    inherit (inputs) secrets;
  };
  lib = inputs.nixpkgs.lib;
in
{
  pkgsFor = system: inputs.nixpkgs.legacyPackages.${system};

  filesIn =
    dir: lib.fileset.toList (lib.fileset.fileFilter (file: lib.hasSuffix ".nix" file.name) dir);

  fromRoot =
    path:
    builtins.path {
      path = "${inputs.self}/${path}";
      name = baseNameOf path;
    };

  mkSystem =
    hostname: system:
    inputs.nixpkgs.lib.nixosSystem {
      # nixpkgsPatcher = {
      #   inherit inputs;
      #   nixpkgs = inputs.nixpkgs-unstable;
      # };
      specialArgs = specialArgs // {
        inherit system;
      };
      modules = [
        ../hosts/${hostname}/configuration.nix
        # inputs.nix-maid.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        (
          { config, ... }:
          {
            # maid.sharedModules = (myLib.filesIn ../maid);
            # users.users.${config.me.user}.maid = {
            #   imports = [ ../hosts/${hostname}/maid.nix ];
            #   _module.args.osConfig = config;
            # };
            home-manager.users.${config.me.user} = import ../hosts/${hostname}/home.nix;
            home-manager.extraSpecialArgs = specialArgs // {
              inherit system;
            };
          }
        )
      ];
    };

  syncthingDirConfig =
    {
      path,
      devices,
      type ? "sendreceive",
      extraConfig ? { },
    }:
    {
      path = "~/" + path;
      inherit type;
      inherit devices;
      versioning =
        if type != "sendonly" then
          {
            type = "simple";
            params = {
              keep = "5";
              cleanoutDays = "14";
            };
          }
        else
          null;
    }
    // extraConfig;

  notifyOnServiceFailure = service: {
    ${service} = {
      unitConfig.OnFailure = "service-failure-notify@%N.service";
    };
  };

  bar.font-size = 13;
  hex = lib.mapAttrs (name: value: lib.removePrefix "#" value) myLib.palette;
  light_hex = lib.mapAttrs (name: value: lib.removePrefix "#" value) myLib.light_palette;

  palette = {
    bg0_dark = "#000000";

    bg0 = "#000000";
    bg1 = "#202020";
    bg2 = "#404040";
    bg3 = "#606060";
    fg4 = "#808080";
    fg3 = "#808080";
    fg2 = "#A0A0A0";
    fg1 = "#A0A0A0";
    fg0 = "#A0A0A0";

    red = "#d4726f";
    green = "#7eb882";
    yellow = "#606060";
    cyan = "#404040";
    blue = "#A0A0A0";
    magenta = "#808080";
    orange = "#606060";
  };

  light_palette = {
    bg0_dark = "#FFFFFF";

    bg0 = "#FFFFFF";
    bg1 = "#BFBFBF";
    bg2 = "#9F9F9F";
    bg3 = "#9F9F9F";
    fg4 = "#7F7F7F";
    fg3 = "#7F7F7F";
    fg2 = "#5F5F5F";
    fg1 = "#5F5F5F";
    fg0 = "#5F5F5F";

    red = "#a8423f";
    yellow = "#9F9F9F";
    green = "#4a7c4e";
    cyan = "#7F7F7F";
    blue = "#5F5F5F";
    magenta = "#7F7F7F";
    orange = "#9F9F9F";
  };

  # gruvbox
  # palette = {
  #   bg0_dark = "#131516";
  #   bg0 = "#1d2021";
  #   bg0_light = "#282828";
  #   bg1 = "#3c3836";
  #   bg2 = "#504945";
  #   bg3 = "#665c54";
  #   fg4 = "#928374";
  #   fg3 = "#a89984";
  #   fg2 = "#bdae93";
  #   fg1 = "#d5c4a1";
  #   fg0 = "#ebdbb2";
  #   red = "#cc241d";
  #   yellow = "#d79921";
  #   green = "#98971a";
  #   cyan = "#689d6a";
  #   blue = "#458588";
  #   magenta = "#b16286";
  #   orange = "#d65d0e";
  # };

  network = {
    lan = {
      subnet = "192.168.1.0/24";
      gateway = "192.168.1.254";
      addr = {
        server = "192.168.1.95";
        desktop = "192.168.1.120";
        laptop = "192.168.1.198";
      };
    };
    vpn = {
      subnet = "10.0.0.0/24";
      addr = {
        server = "10.0.0.1";
        laptop = "10.0.0.2";
        phone = "10.0.0.3";
      };
    };
  };

  media-group = "media";

  ssh-keys = {
    yugen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJahc82zjVv6+UDKi3eN9oZRfGRE7zhBivo5TYtDLe53 yugen";
    ryusei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK ryusei";
    kumo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcGpmfziJoYbPbfdZi/REVStrNgl+F8lwVf1t2oLdaZ kumo";
    hikari = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVezt2Z6LhXPzAMhn6nJ0zXbrWXd93+QKmBqJ+8uE+s hikari";
  };
}
