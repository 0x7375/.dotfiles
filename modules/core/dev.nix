{ inputs, ... }:

{
  flake.modules.darwin.dev = { pkgs, ... }: {
    packages = with pkgs; [
      # karabiner
      nodejs_24
    ];
  };

  flake.modules.generic.dev =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        gnumake
        bacon
      ];

      hj.xdg.config.files."bacon/prefs.toml".text = # toml
        ''
          help_line = false
          hide_scrollbar = true
          [keybindings]
          g = "scroll-to-top"
          shift-g = "scroll-to-bottom"
          k = "scroll-lines(-1)"
          j = "scroll-lines(1)"
          ctrl-u = "scroll-page(-1)"
          ctrl-d = "scroll-page(1)"

          [skin]
          status_fg = 0
          status_bg = 7

          project_name_badge_fg = 0
          project_name_badge_bg = 7

          job_label_badge_fg = 0
          job_label_badge_bg = 6

          computing_fg = 0
          computing_bg = 6

          status_key_fg = 0
          command_error_badge_fg = 0
          errors_badge_fg = 0
          warnings_badge_fg = 0
        '';
    };

  flake.modules.nixos.dev =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        go
        delve

        # nodePackages.eas-cli
        # nodejs_24
        # deno

        # haskell
        # ghc

        php
        # nodePackages.intelephense

        # java
        zulu

        # c
        clang-tools
        gcc
        bear
        gdb

        unstable.rustc
        unstable.cargo
        unstable.clippy
        inputs.maudfmt.packages.${pkgs.stdenv.hostPlatform.system}.default

        tailwindcss_4

        python3
        taplo
      ];
    };
}
