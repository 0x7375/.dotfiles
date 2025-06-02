{
  programs.git = {
    enable = true;
    includes =
      let
        sourcehut = {
          user = {
            name = "ayko";
            email = "sourcehut.buckshot@0xaa.me";
          };
          commit = {
            gpgSign = false;
          };
        };
        github = {
          user = {
            name = "0x7375";
            email = "github.little@0xaa.me";
          };
        };
        codeberg = {
          user = {
            name = "0x7E";
            email = "codeberg.unmapped@0xaa.me";
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
