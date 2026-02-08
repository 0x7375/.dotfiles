{
  config,
  lib,
  pkgs,
  inputs,
  mkBundle,
  ...
}:

{
  imports = with lib; [
    (mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
    (mkAliasOptionModule [ "vars" ] [ "environment" "variables" ])
    (mkAliasOptionModule [ "aliases" ] [ "environment" "shellAliases" ])
    (mkAliasOptionModule [ "activation" ] [ "system" "activationScripts" "postActivation" "text" ])
    (mkAliasOptionModule [ "preActivation" ] [ "system" "activationScripts" "preActivation" "text" ])
  ];

  options = {
    unfree-packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of unfree packages to allow installing.";
    };
  };

  config = mkBundle {
    environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;

    nixos.systemd.user.services.dotfiles-setup = {
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
  };
}
