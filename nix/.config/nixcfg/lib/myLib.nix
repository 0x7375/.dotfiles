{ inputs, ... }:
let
  myLib = (import ./myLib.nix) { inherit inputs; };
  specialArgs = {
    inherit inputs myLib;
    inherit (inputs) secrets;
  };
  lib = inputs.nixpkgs.lib;
in
rec {
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
    config: system:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs // {
        inherit system;
      };
      modules = [
        config
      ];
    };

  mkHome =
    config: system:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;
      extraSpecialArgs = specialArgs // {
        inherit system;
      };
      modules = [
        config
      ];
    };

  mkSystemWithHome =
    nixosConfig: hmConfig: system:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs // {
        inherit system;
      };
      modules = [
        nixosConfig
        inputs.home-manager.nixosModules.home-manager
        (
          { config, ... }:
          {
            environment.systemPackages = [ inputs.home-manager.packages.${system}.default ];
            home-manager.users.${config.me.user} = import hmConfig;
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
  hex = {
    bg0_dark = "131516";
    bg0 = "1d2021";
    bg1 = "3c3836";
    bg2 = "504945";
    bg3 = "665c54";
    fg4 = "928374";
    fg3 = "a89984";
    fg2 = "bdae93";
    fg1 = "d5c4a1";
    fg0 = "ebdbb2";
    red = "cc241d";
    yellow = "d79921";
    green = "98971a";
    cyan = "689d6a";
    blue = "458588";
    magenta = "b16286";
    orange = "d65d0e";
  };
  palette = {
    bg0_dark = "#131516";
    bg0 = "#1d2021";
    bg0_light = "#282828";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    fg4 = "#928374";
    fg3 = "#a89984";
    fg2 = "#bdae93";
    fg1 = "#d5c4a1";
    fg0 = "#ebdbb2";
    fg0_light = "#fbf1c7";
    red = "#cc241d";
    yellow = "#d79921";
    green = "#98971a";
    cyan = "#689d6a";
    blue = "#458588";
    magenta = "#b16286";
    orange = "#d65d0e";
  };

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
