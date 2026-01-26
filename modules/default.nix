{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

{
  imports = [
    (lib.mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
    (lib.mkAliasOptionModule [ "vars" ] [ "environment" "variables" ])
    (lib.mkAliasOptionModule [ "aliases" ] [ "environment" "shellAliases" ])
  ];

  options = {
    unfree-packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of unfree packages to allow installing.";
    };
  };

  config = lib.mkMerge [
    {
      environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;
    }
    (lib.optionalAttrs (options ? systemd) {
      systemd.user.services.dotfiles-setup = {
        description = "Clone dotfiles repository";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "clone-dotfiles" ''
            if [[ ! -e ${config.me.flakeDir} ]]; then
              ${lib.getExe pkgs.git} -c core.sshCommand="${lib.getExe' pkgs.openssh "ssh"} -o StrictHostKeyChecking=accept-new" clone codeberg:0x7E/.dotfiles ${config.me.flakeDir}
            fi
          '';
          RemainAfterExit = true;
        };
        wantedBy = [ "default.target" ];
      };
    })
  ];
}
