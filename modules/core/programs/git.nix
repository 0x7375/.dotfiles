{
  lib,
  pkgs,
  config,
  mkBundle,
  secrets,
  ...
}:

let
  inherit (config.me)
    hosts
    host
    home
    user
    ;

  github = pkgs.writeText "github" ''
    [user]
      email = "github.little@0xaa.me"
      name = "0x7375"
  '';
  sourcehut = pkgs.writeText "sourcehut" ''
    [user]
      email = "sourcehut.buckshot@0xaa.me"
      name = "ayko"
  '';
  codeberg = pkgs.writeText "codeberg" ''
    [user]
      email = "codeberg.unmapped@0xaa.me"
      name = "0x7E"
  '';

  allSigningKeys = hosts.yubikey.sshPublicKeys ++ hosts.mach.sshPublicKeys;
in
lib.mkMerge [
  (mkBundle {
    packages = [ pkgs.git ];

    hj.xdg.config.files."git/ignore".text = ''
      .DS_Store
    '';

    hj.xdg.config.files."git/config".text = ''
      [commit]
        gpgsign = true

      [credential]
        helper = "store"

      [gpg]
        format = "ssh"

      [gpg "openpgp"]
        program = "${lib.getExe' pkgs.gnupg "gpg"}"

      [gpg "ssh"]
        allowedSignersFile = "~/.ssh/allowed_signers"

      [init]
        defaultBranch = "main"

      [url "git@codeberg.org:"]
        insteadOf = "codeberg:"

      [url "git@git.sr.ht:"]
        insteadOf = "sourcehut:"

      [url "git@git.unicaen.fr:"]
        insteadOf = "uni:"

      [url "git@github.com:"]
        insteadOf = "github:"

      [url "https://codeberg.org/"]
        insteadOf = "cb:"

      [url "https://git.sr.ht/"]
        insteadOf = "sh:"

      [url "https://github.com/"]
        insteadOf = "gh:"

      [url "https://redmine-etu.unicaen.fr/git/"]
        insteadOf = "forge:"

      [user]
        signingkey = "${pkgs.writeText "key.pub" host.sshSigning.key}"

      [includeIf "hasconfig:remote.*.url:github:*/**"]
        path = "${github}"

      [includeIf "hasconfig:remote.*.url:gh:*/**"]
        path = "${github}"

      [includeIf "hasconfig:remote.*.url:sourcehut:*/**"]
        path = "${sourcehut}"

      [includeIf "hasconfig:remote.*.url:sh:*/**"]
        path = "${sourcehut}"

      [includeIf "hasconfig:remote.*.url:codeberg:*/**"]
        path = "${codeberg}"

      [includeIf "hasconfig:remote.*.url:cb:*/**"]
        path = "${codeberg}"
    '';

    hj.files.".ssh/allowed_signers".text = lib.concatMapStrings (k: "* ${k}\n") allSigningKeys;

    darwin =
      let
        secretivePath = "${home}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      in
      {
        hj.xdg.config.files."ssh/config".text = ''
          Host *
            IdentityAgent ${secretivePath}
        '';

        environment.shellInit = ''
          export SSH_AUTH_SOCK=${secretivePath}
        '';
      };

    nixos = {
      systemd.user.services.ssh-add = lib.mkIf config.me.secrets.enable {
        description = "Add keys to SSH agent";
        after = [ "ssh-agent.service" ];
        bindsTo = [ "ssh-agent.service" ];
        upheldBy = [ "ssh-agent.service" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${lib.getExe' pkgs.coreutils "sleep"} 1";
          Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
          ExecStart = "${lib.getExe' pkgs.openssh "ssh-add"} %h/.ssh/${host.sshSigning.path}";
          RemainAfterExit = "yes";
        };
      };

      systemd.user.services.ssh-agent = lib.mkIf config.me.secrets.enable {
        wantedBy = [ "default.target" ];
        description = "SSH authentication agent";
        documentation = [ "man:ssh-agent(1)" ];
        serviceConfig.ExecStart = "${lib.getExe' pkgs.openssh "ssh-agent"} -D -a %t/ssh-agent";
      };

      environment.shellInit =
        # bash
        ''
          if [ -z "$SSH_AUTH_SOCK" ]; then
            export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
          fi
        '';
    };
  })
  (lib.mkIf config.me.secrets.enable {
    sops.secrets.git-config = {
      sopsFile = "${secrets}/uni-git-config.ini";
      format = "ini";
      owner = user;
    };

    hj.xdg.config.files."git/config".text = lib.mkAfter ''
      [includeIf "hasconfig:remote.*.url:uni:*/**"]
        path = ${config.sops.secrets.git-config.path}
      [includeIf "hasconfig:remote.*.url:forge:**"]
        path = ${config.sops.secrets.git-config.path}
    '';
  })
]
