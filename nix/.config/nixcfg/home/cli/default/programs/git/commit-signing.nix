{
  lib,
  config,
  ...
}:

let
  pk = config.me.publicKey;
in
lib.mkIf config.me.gui.enable {
  programs.git = {
    extraConfig = {
      # user.signingkey = pk;
      # gpg.format = "ssh";
      # commit.gpgsign = true;
      # gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  # home.file.".ssh/allowed_signers".text = "* ${pk}";
}
