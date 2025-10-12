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
  hexLight = lib.mapAttrs (name: value: lib.removePrefix "#" value) myLib.light;

  # colors from https://github.com/sainnhe/gruvbox-material
  # take neovim monochrome theme colors otherwise
  palette = {
    bg0_dark = "#000000";
    bg0 = "#0E0E0E";
    bg0_light = "#1A1A1A";
    bg1 = "#262626";
    bg2 = "#333333";
    bg3 = "#404040";
    fg4 = "#666666";
    fg3 = "#808080";
    fg2 = "#999999";
    fg1 = "#B3B3B3";
    fg0 = "#D4D4D4";
    fg0_light = "#E6E6E6";

    red = "#E96962";
    yellow = "#D7A657";
    green = "#A8B665";
    cyan = "#89B482";
    blue = "#7DAEA3";
    magenta = "#D3869B";
    orange = "#E68A4E";
  };

  light = {
    bg0_dark = "#FFFFFF";
    bg0 = "#EEEEEE";
    bg0_light = "#EBEBEB";
    bg1 = "#E0E0E0";
    bg2 = "#D6D6D6";
    bg3 = "#CCCCCC";
    fg4 = "#999999";
    fg3 = "#808080";
    fg2 = "#666666";
    fg1 = "#4D4D4D";
    fg0 = "#2B2B2B";
    fg0_light = "#1A1A1A";

    red = "#C04A4A";
    yellow = "#B37109";
    green = "#6B782E";
    cyan = "#4C7A5D";
    blue = "#45707A";
    magenta = "#945E80";
    orange = "#C25E0A";
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
  #   fg0_light = "#fbf1c7";
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
