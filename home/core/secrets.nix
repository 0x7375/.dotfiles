{
  secrets,
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf config.me.secrets.enable {
    sops.age.sshKeyPaths = [ "/home/${config.me.user}/.ssh/id_ed25519" ];
    sops.defaultSecretsMountPoint = "/run/user/${toString config.me.uid}/secrets.d";
    sops.defaultSopsFile = "${secrets}/default.yaml";

    # owner can be root for some reason
    systemd.user.tmpfiles.rules = [
      "d /home/${config.me.user}/.config/sops-nix 0755 ${config.me.user} users - -"
    ];

    home.activation.generateSopsKey =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          [[ ! -e /home/${config.me.user}/.config/sops/age/keys.txt ]] && {
            run mkdir -p /home/${config.me.user}/.config/sops/age
            run ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${builtins.head config.sops.age.sshKeyPaths} \
              -o /home/${config.me.user}/.config/sops/age/keys.txt
          }
        '';

    systemd.user.services.dotfiles-setup = {
      Unit = {
        Description = "Clone dotfiles repository";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "clone-dotfiles" ''
          if [[ ! -e ${config.me.flakeDir} ]]; then
            ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new" clone codeberg:0x7E/.dotfiles ${config.me.flakeDir}
          fi
        '';
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
