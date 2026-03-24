{
  flake.shared.wm =
    {
      pkgs,
      ...
    }:
    {
      unfree-packages = [
        "discord"
        "omnissa-horizon-client"
      ];

      packages =
        with pkgs;
        let
          st = pkgs.st.overrideAttrs (old: {
            src = fetchFromGitea {
              domain = "codeberg.org";
              owner = "0x7E";
              repo = "st";
              rev = "main";
              sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
            };
          });
        in
        [
          my.swap-theme
          my.backup-vault
          texliveMedium
          typst
          qbittorrent
          # st
        ];

    };

  flake.nixos.wm =
    { lib, pkgs, ... }:
    lib.mkMerge [
      {
        unfree-packages = [
          "discord"
          "omnissa-horizon-client"
        ];

        me.wm.assign = [
          {
            type = "class";
            name = "vesktop";
            workspace = "4";
          }
        ];

        packages = with pkgs; [
          # (auto.discord.override {
          #   # withOpenASAR = true;
          #   withVencord = true;
          # })
          vesktop
          my.generate-icons
          omnissa-horizon-client
          auto.signal-desktop
          # jetbrains.idea-community
        ];
      }
      {
        packages = [ pkgs.gaphor ];

        xdg.mimeApps.defaultApplications = {
          "application/x-gaphor" = "gaphor.desktop";
        };

        hj.xdg.data.files."mime/packages/gaphor.xml".text = # xml
          ''
            <?xml version="1.0" encoding="UTF-8"?>
            <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
              <mime-type type="application/x-gaphor">
                <comment>Gaphor UML diagram</comment>
                <glob pattern="*.gaphor"/>
                <sub-class-of type="application/xml"/>
              </mime-type>
            </mime-info>
          '';
      }
    ];
}
