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

    userActivation = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Alias for respective user activation method on macos/nixos, don't use single quotes on macos";
    };
  };

  config = mkBundle {
    security.sudo.extraConfig = ''
      Defaults env_keep += "HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME"
    '';

    environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;

    darwin.system.activationScripts.postActivation.text = lib.mkIf (config.userActivation != "") ''
      sudo -H -u ${config.me.user} ${lib.getExe pkgs.bash} -c '
        ${config.userActivation}
      '
    '';

    nixos = {
      security.polkit.enable = true;

      system.userActivationScripts.userActivation.text = config.userActivation;

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
    };
  };
}
