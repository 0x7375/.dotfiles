{
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
        codeberg = {
          user = {
            name = "0xB0F";
            email = "codeberg.whooping751@simplelogin.com";
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
        {
          condition = "hasconfig:remote.*.url:codeberg:*/**";
          contents = codeberg;
        }
        {
          condition = "hasconfig:remote.*.url:cb:*/**";
          contents = codeberg;
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
        "https://codeberg.org/" = {
          insteadOf = [
            "cb:"
          ];
        };
        "git@codeberg.org:" = {
          insteadOf = [
            "codeberg:"
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
