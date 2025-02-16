{ config, ... }:

{
  imports = [
    ./commit-signing.nix
  ];

  home.activation.moveCredentials = # bash
    ''
      [ -e "$HOME/.git-credentials" ] && mv $HOME/.git-credentials ~/.cache/git-credentials
    '';

  programs.git = {
    enable = true;
    includes =
      let
        sourcehut = {
          user = {
            name = "ayko";
            email = "sr.fastness739@aleeas.com";
          };
          commit = {
            gpgSign = false;
          };
        };
        github = {
          user = {
            name = "0xB0F";
            email = "github.gimmick175@slmails.com";
          };
        };
      in
      [
        {
          condition = "hasconfig:remote.*.url:github:*/**";
          contents = github;
        }
        {
          condition = "hasconfig:remote.*.url:gh:*/**";
          contents = github;
        }
        {
          condition = "hasconfig:remote.*.url:sourcehut:*/**";
          contents = sourcehut;
        }
        {
          condition = "hasconfig:remote.*.url:sh:*/**";
          contents = sourcehut;
        }
      ];
    ignores = [ ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      credential.helper = "store";
      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
          ];
        };
        "git@github.com:" = {
          insteadOf = [
            "github:"
          ];
        };
        "https://git.sr.ht/" = {
          insteadOf = [
            "sh:"
          ];
        };
        "git@git.sr.ht:" = {
          insteadOf = [
            "sourcehut:"
          ];
        };
        "https://redmine-etu.unicaen.fr/git/" = {
          insteadOf = [
            "forge:"
          ];
        };
        "git@git.unicaen.fr:" = {
          insteadOf = [
            "uni:"
          ];
        };
      };
    };
  };
}
