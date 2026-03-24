{
  flake.nixos.core =
    {
      lib,
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" config.me.user ])
      ];

      users.users.${config.me.user} = {
        isNormalUser = true;
        home = config.me.home;
        initialPassword = "pw123";
        initialHashedPassword = lib.mkForce null;
        uid = config.me.uid;
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

      hjem = {
        linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
        users.${config.me.user}.enable = true;
        clobberByDefault = true;
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
