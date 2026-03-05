{
  pkgs,
  secrets,
  config,
  lib,
  mkBundle,
  ...
}:

{
  options.me.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy secrets using sops-nix";
    };

    tpm = {
      enable = lib.mkEnableOption "Use tmp to decrypt sops secrets";
      file = lib.mkOption {
        type = lib.types.path;
        description = "Path to age identity tpm file";
      };
    };
  };

  config = lib.mkIf config.me.secrets.enable (mkBundle {
    packages = [ pkgs.sops ];

    sops.defaultSopsFile = "${secrets}/default.yaml";
    sops.gnupg.sshKeyPaths = [ ];
    sops.age.sshKeyPaths = [ ];

    nixos = lib.mkMerge [
      {
        sops.useSystemdActivation = true;

        hj.xdg.config.files."sops/age/sk_backup" = {
          text = builtins.readFile ./age-fido2-backup.txt;
          type = "copy";
          permissions = "0600";
        };

        hj.xdg.config.files."sops/age/sk_main" = {
          text = builtins.readFile ./age-fido2-main.txt;
          type = "copy";
          permissions = "0600";
        };

        vars.SOPS_AGE_KEY_FILE = "${config.me.home}/.config/sops/age/${config.me.host.sopsDecryptionKey}";
      }
      (lib.mkIf config.me.secrets.tpm.enable {
        environment.etc."tpm_key".source = config.me.secrets.tpm.file;

        sops.age = {
          keyFile = "/etc/tpm_key";
          plugins = with pkgs; [ unstable.age-plugin-tpm ];
        };

        packages = with pkgs; [
          age-plugin-tpm
          tpm2-tools
        ];

        security.tpm2 = {
          enable = true;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };
      })
      (lib.mkIf (!config.me.secrets.tpm.enable) {
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      })
    ];

    darwin = {
      packages = [ pkgs.age-plugin-se ];

      sops.age = {
        keyFile = "/var/lib/sops-nix/se-identity.txt";
        plugins = with pkgs; [ age-plugin-se ];
      };
    };
  });
}
