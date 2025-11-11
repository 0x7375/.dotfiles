{
  config,
  lib,
  pkgs,
  inputs,
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
  config = {
    environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;

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

    # NOTE: run `bat cache --build` in an empty directory to work
    # around failure when ~/cache exists
    # https://github.com/sharkdp/bat/issues/1726
    system.userActivationScripts.batCache = ''
      (
        export XDG_CACHE_HOME=${config.vars.XDG_CACHE_HOME}
        cd "${pkgs.emptyDirectory}"
        ${lib.getExe pkgs.bat} cache --build
      )
    '';
  };
}
