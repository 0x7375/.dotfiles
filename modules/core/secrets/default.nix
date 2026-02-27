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
        hj.files."sops/age/fido2-backup.txt" = {
          text = builtins.readFile ./age-fido2-backup.txt;
          type = "copy";
          permissions = "0600";
        };

        hj.xdg.config.files."sops/age/fido2-main.txt" = {
          text = builtins.readFile ./age-fido2-main.txt;
          type = "copy";
          permissions = "0600";
        };
      }
      (lib.mkIf config.me.secrets.tpm.enable {
        hj.xdg.config.files."sops/age/keys.txt".source = config.me.secrets.tpm.file;

        packages = with pkgs; [
          age-plugin-tpm
          tpm2-tools
        ];

        security.tpm2 = {
          enable = true;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };

        sops.age = {
          keyFile = "${config.me.home}/.config/sops/age/keys.txt";
          plugins = with pkgs; [ age-plugin-tpm ];
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
