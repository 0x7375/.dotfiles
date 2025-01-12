{
  lib,
  config,
  pkgs,
  ...
}:

let
  pk = config.me.gitPublicKey;
in
lib.mkIf config.me.gui.enable {
  programs.git = {
    extraConfig = {
      user.signingkey = pk;
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  home.file.".ssh/allowed_signers".text = "* ${pk}";
}
