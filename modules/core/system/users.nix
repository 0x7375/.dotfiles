{
  flake.shared.core =
    {
      pkgs,
      config,
      lib,
      inputs,
      ...
    }:
    {
      imports = [
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.me.user ])
      ];

      hjem = {
        linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
        users.${config.me.user}.enable = true;
        clobberByDefault = true;
      };
    };

  flake.nixos.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      users.users.${config.me.user} = {
        inherit (config.me) uid home;
        isNormalUser = true;
        initialPassword = "pw123";
        initialHashedPassword = lib.mkForce null;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "input"
        ];
      };

      users.users.root = {
        initialPassword = "root";
        initialHashedPassword = lib.mkForce null;
      };
    };

  flake.nixos.secrets =
    {
      lib,
      config,
      ...
    }:
    {
      users.mutableUsers = false;

      sops.secrets.user_pw.neededForUsers = true;
      sops.secrets.root_pw.neededForUsers = true;

      users.users.${config.me.user} = {
        initialPassword = lib.mkForce null;
        hashedPasswordFile = config.sops.secrets.user_pw.path;
      };

      users.users.root = {
        initialPassword = lib.mkForce null;
        hashedPasswordFile = config.sops.secrets.root_pw.path;
      };
    };
}
