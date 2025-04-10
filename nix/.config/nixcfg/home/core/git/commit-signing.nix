{
  lib,
  pkgs,
  config,
  ...
}:

let
  pk = config.me.publicKey;
in
{
  programs.git = {
    extraConfig = {
      user.signingkey = pk;
      gpg.format = "ssh";
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  home.file.".ssh/allowed_signers".text = "* ${pk}";

  services.ssh-agent.enable = true;
  systemd.user.services.ssh-add = lib.mkIf config.me.secrets.enable {
    Unit = {
      Description = "Add keys to SSH agent";
      After = [ "ssh-agent.service" ];
      Requires = [ "ssh-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      # Wait a bit for the socket to be ready
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = "yes";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
