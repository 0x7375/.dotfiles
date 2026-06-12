# List non-persisted files
pkgs:
pkgs.writeShellApplication {
  name = "fs-diff";
  runtimeInputs = with pkgs; [
    gawk
    util-linux
  ];
  text = ''
    set -euo pipefail

    DEVICE="/dev/mapper/crypted"

    TMPDIR=$(mktemp -d)
    MNT_ROOT="$TMPDIR/root"
    MNT_HOME="$TMPDIR/home"
    MNT_PERSIST="$TMPDIR/persist"

    cleanup() {
        sudo umount "$MNT_PERSIST" 2>/dev/null || true
        sudo umount "$MNT_ROOT" 2>/dev/null || true
        sudo umount "$MNT_HOME" 2>/dev/null || true
        rmdir "$MNT_PERSIST" "$MNT_ROOT" "$TMPDIR" 2>/dev/null || true
    }
    trap cleanup EXIT

    mkdir -p "$MNT_HOME" "$MNT_ROOT" "$MNT_PERSIST"
    sudo mount -o ro,noatime,subvol=root "$DEVICE" "$MNT_ROOT"
    sudo mount -o ro,noatime,subvol=@home "$DEVICE" "$MNT_HOME"
    sudo mount -o ro,noatime,subvol=@persist "$DEVICE" "$MNT_PERSIST"

    EXCLUDES=(
        "$MNT_ROOT/nix"
        "$MNT_ROOT/persist"
        "$MNT_ROOT/home"
        "$MNT_ROOT/var/log"
        "$MNT_ROOT/swap"
        "$MNT_ROOT/boot"
        "$MNT_ROOT/proc"
        "$MNT_ROOT/sys"
        "$MNT_ROOT/dev"
        "$MNT_ROOT/run"
        "$MNT_ROOT/tmp"
    )

    prune_args=()
    for d in "''${EXCLUDES[@]}"; do
        prune_args+=(-path "$d" -prune -o)
    done

    # replace entries with 10+ loose files into /*
    condense() {
        awk '{
            dir = $0
            sub("/[^/]*$", "", dir)
            count[dir]++
            lines[++n] = $0
            paths[$0] = dir
        }
        END {
            for (i=1; i<=n; i++) {
                dir = paths[lines[i]]
                if (count[dir] > 10) {
                    if (!seen[dir]++) print dir "/*"
                } else {
                    print lines[i]
                }
            }
        }' | sort
    }

    echo "ROOT:"
    sudo find "$MNT_ROOT" \
        "''${prune_args[@]}" \
        \( -not -type d -not -type l -print \) |
        while IFS= read -r full_path; do
            rel="''${full_path#"$MNT_ROOT"}"
            if [[ ! -e "$MNT_PERSIST$rel" ]]; then
                echo "  $rel"
            fi
        done | condense

    echo "HOME:"
    sudo find "$MNT_HOME" \
        "''${prune_args[@]}" \
        \( -not -type d -not -type l -print \) |
        while IFS= read -r full_path; do
            rel="/home/''${full_path#"$MNT_HOME"/}"
            if [[ ! -e "$MNT_PERSIST$rel" ]]; then
                echo "  $rel"
            fi
        done | condense
  '';
}
