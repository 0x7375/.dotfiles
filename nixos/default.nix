{
  config,
  lib,
  pkgs,
  inputs,
  myLib,
  ...
}:

{
  imports = [
    ../lib
    (lib.mkAliasOptionModule [ "packages" ] [ "environment" "systemPackages" ])
    (lib.mkAliasOptionModule [ "vars" ] [ "environment" "variables" ])
  ]
  ++ myLib.filesIn ../modules;

  environment.etc.nixcfg.source = pkgs.lib.cleanSource inputs.self;

  hj.xdg.config.files."nixpkgs/config.nix".text = # nix
    ''
      {
        allowUnfree = true;
      }
    '';

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
}
