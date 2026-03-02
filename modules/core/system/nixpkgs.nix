{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  pkgs-path = ../../../packages;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfree-packages;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
      };
      auto = import inputs.auto-update {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
      };

      # ffmpeg = prev.ffmpeg.override { withFullDeps = true; };

      # nix =
      #   if config.me.wm.enable then
      #     prev.nix.overrideAttrs (old: {
      #       postPatch = ''
      #         for file in \
      #           src/libfetchers/github.cc \
      #           src/libflake/flake/url-name.cc \
      #           src/libexpr/primops/fetchTree.cc \
      #           tests/nixos/sourcehut-flakes.nix \
      #           src/libfetchers-tests/access-tokens.cc \
      #           src/libflake-tests/url-name.cc
      #         do
      #           [[ -f $file ]] && substituteInPlace "$file" --replace-fail "sourcehut" "codeberg"
      #         done
      #         substituteInPlace src/libfetchers/github.cc --replace-fail "git.sr.ht" "codeberg.org"
      #       '';
      #     })
      #   else
      #     prev.nix;

      #   nil = prev.nil.override (old: {
      #     rustPlatform = old.rustPlatform // {
      #       buildRustPackage = args: old.rustPlatform.buildRustPackage (args // rec {
      #         version = "2f3ed6348bbf1440fcd1ab0411271497a0fbbfa4";
      #         src = pkgs.fetchFromGitHub {
      #           owner = "oxalica";
      #           repo = "nil";
      #           rev = version;
      #           sha256 = "sha256-o4tqlTzi9kcVub167kTGXgCac9jM3kW4+v9MH/ue4Hk=";
      #         };
      #         cargoHash = "sha256-um8D8NO30BbKTTaiyJ8nURHW3cZlmdTC+a530lxKt3Q=";
      #       });
      #     };
      #   });

      polybar =
        (prev.polybar.override {
          i3Support = true;
        }).overrideAttrs
          (old: {
            # change ellipsis on overflow from ... to ~
            postPatch = ''
              substituteInPlace include/drawtypes/label.hpp \
                --replace-fail "m_maxlen >= 3" "m_maxlen >= 1"
              substituteInPlace src/drawtypes/label.cpp \
                --replace-fail "m_maxlen - 3) + \"...\"" "m_maxlen - 1) + \"~\""
              substituteInPlace src/drawtypes/label.cpp \
                --replace-fail "maxlen < 3" "maxlen < 1"
            '';
          });

      # nh = prev.nh.overrideAttrs (old: {
      #   postPatch = ''
      #     substituteInPlace src/search.rs \
      #       --replace-fail "print_hyperlink!(position, format!(\"file://{nixpkgs_path}/{postion_trimmed}\"));" "print_hyperlink!(format!(\"https://github.com/NixOS/nixpkgs/blob/nixos-unstable/{postion_trimmed}\"), \"\");"
      #   '';
      # });

      # derivations
      fonts = {
        CartographCF = prev.callPackage (pkgs-path + /derivations/fonts/CartographCF.nix) { };
        InconsolataNF = prev.callPackage (pkgs-path + /derivations/fonts/InconsolataNF.nix) { };
      };

      # namespace for scripts: e.g. "my.tmux-sessionizer"
      my = builtins.listToAttrs (
        map (path: {
          name = (lib.removeSuffix ".nix" (baseNameOf path));
          value = import path {
            inherit
              lib
              config
              pkgs
              inputs
              ;
          };
        }) (lib.my.filesIn (pkgs-path + /scripts))
      );
    })
  ]
  ++ [ inputs.nur.overlays.default ];
}
