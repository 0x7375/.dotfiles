{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      packages = [ pkgs.my.notify ];

      nixpkgs.overlays = [
        (final: prev: {
          my = (prev.my or { }) // {
            # wrapper around notify-send to use tabler-icons, each icon/color pair is fetched once and cached
            notify = prev.writeShellScriptBin "notify" ''
              _tabler() {
                local name=$1
                source "''$TINTED_DIR/palette.env"

                local out="''$HOME/.cache/tabler-icons/$name-$fg0.png"
                [[ -f "$out" ]] && { printf '%s' "$out"; return; }

                mkdir -p "$(dirname "$out")"
                ${prev.lib.getExe prev.curl} -sf \
                  "https://cdn.jsdelivr.net/npm/@tabler/icons/icons/outline/$name.svg" \
                  | sed "s/currentColor/#''${fg0}/g" \
                  | ${prev.lib.getExe prev.librsvg} -w 48 -h 48 > "$out"
                printf '%s' "$out"
              }

              args=("$@")
              new=()
              i=0
              while (( i < ''${#args[@]} )); do
                case "''${args[i]}" in
                  --icon=*)
                    new+=("--icon=$(_tabler "''${args[i]#--icon=}")") ;;
                  -i)
                    i=$(( i + 1 ))
                    new+=("--icon=$(_tabler "''${args[i]}")") ;;
                  *)
                    new+=("''${args[i]}") ;;
                esac
                i=$(( i + 1 ))
              done

              exec ${prev.lib.getExe prev.libnotify} "''${new[@]}"
            '';
          };
        })
      ];
    };
}
