{
  lib,
  config,
  pkgs,
  ...
}:

let
  ctpv = (
    pkgs.ctpv.override {
      ueberzug = pkgs.ueberzugpp;
      bat = pkgs.bat;
    }
  );
  gui = config.me.gui.enable;
in
{
  nixpkgs.overlays = [
    (
      final: prev:
      {
        lf = prev.lf.overrideAttrs (old: rec {
          version = "0d5ffcdb04170457edcd26da0e972fddf4e0fb2d";
          src = pkgs.fetchFromGitHub {
            owner = "CatsDeservePets";
            repo = old.src.repo;
            rev = version;
            sha256 = "sLv2dUdRs65GYEpq3yrmktdV9QwZiCO/8dwEeq4nEhk=";
          };
          vendorHash = "sha256-ZShpWCfEVPLafrn3MvtxkRsBvwUEOiLBs1gZhKSBrsQ=";
        });
      }
      // (lib.optionalAttrs (config.me.hostname != "hikari") {
        ouch = prev.ouch.override {
          enableUnfree = true;
        };
      })
      // (lib.optionalAttrs (prev.stdenv.hostPlatform.isAarch64) {
        ctpv = prev.ctpv.overrideAttrs (old: {
          CFLAGS = (old.CFLAGS or "") + " -fsigned-char";
        });
      })
    )
  ];

  packages = [
    pkgs.lf
    pkgs.ouch
  ]
  ++ lib.optionals gui [
    ctpv
    pkgs.ueberzugpp
    # pkgs.pistol
    pkgs.poppler_utils
    pkgs.libreoffice
  ];

  hj.xdg.config.files."ctpv/config" = {
    enable = gui;
    text = ''
      # set chafasixel

      preview null .env .git-credentials .keyring {{
          echo "preview disabled"
      }}

      # preview image image/* {{
      #   chafa -s "''${w}x''${h}" -f sixels --polite on "$f"
      # }}
    '';
  };

  hj.xdg.config.files."lf/lfrc".text =
    let
      inherit (config.me) user uid;
      confirm-key = "s";
      no-confirm =
        keys: lib.concatStringsSep "\n" (map (key: "vmap ${key} push ${confirm-key}${key}") keys);
    in
    ''
      set filesep "\n"
      set hidden
      set noicons
      set ifs "\n"
      set ignorecase
      set info
      set promptfmt "\033[34;1m%d\033[0m\033[1m%f\033[0m"
      set ratios "1:1"
      set scrolloff 8
      set shell "zsh"
      set shellopts "-euy"
      set sortby "ext"
      set tabstop 4

      cmd bulkrename ''${{
        export VIMV=1; ${lib.getExe' pkgs.vimv-rs "vimv"} -- $fs

        ${lib.getExe pkgs.lf} -remote "send $id load"
        ${lib.getExe pkgs.lf} -remote "send $id unselect"
      }}

      cmd calc-all-dirsize ''${{
          ${lib.getExe pkgs.lf} -remote "send $id invert"
          ${lib.getExe pkgs.lf} -remote "send $id calcdirsize"
          ${lib.getExe pkgs.lf} -remote "send $id unselect"
          ${lib.getExe pkgs.lf} -remote "send $id show-size"
        }}

      cmd compress %{{
        default_name="$(basename $(echo "$fx" | head -n1))"
        default_name="''${default_name%%.*}.zip"
        
        printf "Archive name (default: $default_name): "
        read new_name
        if [[ -z $new_name ]]; then
          new_name=$default_name
        fi

        ${lib.getExe pkgs.ouch} compress $(realpath --relative-to="$(pwd)" $fx) $new_name 

        ${lib.getExe pkgs.lf} -remote "send $id unselect"
        ${lib.getExe pkgs.lf} -remote "send $id select \"$new_name\""
      }}
      cmd copy-path ''${{
        echo -en "$fx" | tr ' ' '\n' | ${lib.getExe pkgs.xsel} -ib
        ${lib.getExe pkgs.lf} -remote 'send unselect'
        ${lib.getExe pkgs.lf} -remote 'send echo "Path copied to clipboard"'
      }}

      cmd edit ''${{
        if [[ ''${NVIM:-} ]]; then
          ${lib.getExe pkgs.lf} -remote "send $id open"
        else
          $EDITOR $f
        fi
      }}

      cmd edit-new %{{
        printf "File name: "
        read newf
        if [[ -z $newf ]]; then
          ${lib.getExe pkgs.lf} -remote "send $id reload"
          return;
        fi

        ${lib.getExe pkgs.lf} -remote "send $id \$touch \"$newf\""
        ${lib.getExe pkgs.lf} -remote "send $id $\$EDITOR \"$newf\""
      }}

      cmd external-copy ''${{
        echo -en "$fx" | sed 's|^|file://|' | tr ' ' '\n' | ${lib.getExe pkgs.xclip} -i -sel clip -t text/uri-list
        ${lib.getExe pkgs.lf} -remote 'send unselect'
        ${lib.getExe pkgs.lf} -remote 'send echo "Files copied to clipboard"'
      }}

      cmd extract ''${{
        set -f
        ${lib.getExe pkgs.ouch} decompress $fx
        ${lib.getExe' pkgs.trash-cli "trash"} $f
      }}

      cmd follow_link %{{
        ${lib.getExe pkgs.lf} -remote "send $id select '$(readlink $f)'"
      }}

      cmd local-share ''${{
        source ~/.config/zsh/widgets.zsh
        out=$(ks $fx)
        device=$(echo "$out" | head -n 1 | cut -d\  -f3)
        count=$(echo "$out" | tail -n +2 | wc -l)

        ${lib.getExe pkgs.lf} -remote 'send unselect'
        ${lib.getExe pkgs.lf} -remote "send echo '$count Files sent to $device'"
      }}

      cmd mkdir %{{
        printf "Directory name: "
        read newd
        if [[ -z $newd ]]; then
          ${lib.getExe pkgs.lf} -remote "send $id reload"
          return;
        fi

        mkdir -p "$newd"
        ${lib.getExe pkgs.lf} -remote "send $id select \"$newd\""
      }}

      cmd mount-archive ''${{
        if ${lib.getExe pkgs.file} --mime-type "$f" | grep -qE 'application/zip|application/x-tar|application/x-7z-compressed|application/octet-stream|application/gzip'; then
          mntdir="''${f}.mnt"
          mkdir -p "$mntdir"
          ${lib.getExe pkgs.archivemount} "$f" "$mntdir"
          ${lib.getExe pkgs.lf} -remote "send $id cd $mntdir"
        fi
      }}

      cmd move-to-new-dir %{{
        printf "Directory name: "
        read newd
        if [[ -z $newd ]]; then
          ${lib.getExe pkgs.lf} -remote "send $id reload"
          return;
        fi

        mkdir -p -- "$newd"
        mv -- $fx "$newd"
      }}

      cmd on-cd &{{
        if [ -d .git ] || [ -f .git ]; then
            branch="$(git branch --show-current 2>/dev/null)" || true
            fmt="\033[34;1m%d\033[0m\033[1m%f\033[0m \033[32;1mgit:$branch\033[0m"
        else
            fmt="\033[34;1m%d\033[0m\033[1m%f\033[0m"
        fi
        ${lib.getExe pkgs.lf} -remote "send $id set promptfmt \"$fmt\""
      }}
      cmd on-focus-gained :{{
        set cursorparentfmt "\033[7m"
        set cursoractivefmt "\033[7m"
        set cursorpreviewfmt "\033[4m"
      }}
      cmd on-focus-lost :{{
        set cursorparentfmt ""
        set cursoractivefmt ""
        set cursorpreviewfmt ""
      }}

      cmd online-share $${lib.getExe curl} -F"file=@$f" https://0x0.st | ${lib.getExe pkgs.xsel} -ib
      cmd open &mimeopen "$f" > /dev/null 2>&1
      cmd paste-overwrite %{{
          mode=$(head -1 ~/.local/share/lf/files)
          list=$(${lib.getExe' pkgs.gnused "sed"} 1d ~/.local/share/lf/files)
          if [[ $mode == "copy" ]]; then
              cp -r $list .
          elif [[ $mode == "move" ]]; then
              mv $list .
          fi
          ${lib.getExe pkgs.lf} -remote 'send load'
          ${lib.getExe pkgs.lf} -remote 'send clear'
          ${lib.getExe pkgs.lf} -remote "send $id reload"
      }}

      cmd quit-and-cd ''${{
        # absolute paths are needed since we can be in a mount point
        LF_CD_FILE=''${LF_CD_FILE:-/dev/null}
        path=$(pwd)
        
        # make sure we are not in a mount point
        while [[ $path == *".mnt"* ]]; do
          path=$(${lib.getExe' pkgs.coreutils "dirname"} "$path")
        done
        
        echo "$path" > "$LF_CD_FILE"
        ${lib.getExe pkgs.lf} -remote "send $id quit"
      }}

      cmd show-size :set sortby size; set info size; set reverse
      cmd su ''${{
        ${lib.getExe pkgs.lf} -remote "send $id quit"
        sudo lf
      }}

      cmd toggle-executable ''${{
        [[ -x $f ]] && chmod -x "$f" || chmod +x "$f"
        ${lib.getExe pkgs.lf} -remote 'send reload'
      }}

      cmd touch %{{
        printf "File name: "
        read newf
        if [[ -z $newf ]]; then
          ${lib.getExe pkgs.lf} -remote "send $id reload"
          return;
        fi

        touch "$newf"
        ${lib.getExe pkgs.lf} -remote "send $id select \"$newf\""
      }}


      map , find-prev
      map . set hidden!
      map / search
      map ; find-next
      map <c-d> half-down
      map <c-l> mount-archive
      map <c-n> move-to-new-dir
      map <c-o> jump-prev
      map <c-p> $less -R $f
      map <c-r> redraw
      map <c-u> half-up
      map <c-z> $kill -STOP $PPID
      map <enter> open
      map <pgdn>
      map <pgup>
      map <space> $mimeopen --ask $f
      map <tab> jump-next
      map = toggle-executable
      map ? search-back
      map A :rename; cmd-end
      map C clear
      map D delete
      map E $sudoedit $f
      map F find-back
      map G bottom
      map H copy-path
      map I :rename; cmd-home
      map J :updir; down; open
      map K :updir; up; open
      map L
      map M
      map N search-prev
      map O &${lib.getExe pkgs.dragon-drop} $fx
      map P paste-overwrite
      map Q quit-and-cd
      map R :source /home/${user}/.config/lf/lfrc; reload
      map S su
      map V invert
      map W online-share
      map Y external-copy
      map [
      map \"
      map \$ push :$
      map \'
      map ]
      map ` !true
      map a :rename
      map b bulkrename
      map c push A<c-u>
      map d
      map e edit
      map f find
      map g/ cd /
      map gD cd /home/${user}/downloads
      map gL follow_link
      map gN cd /nix/store
      map gP cd /home/${user}/pictures
      map gR cd /run/user/${toString uid}
      map ga cd /usr/share/applications
      map gb cd /home/${user}/.local/bin
      map gc cd /home/${user}/.config
      map gd cd  /home/${user}/documents
      map ge cd ${config.me.flakeDir}
      map gg top
      map gl cd /home/${user}/.local
      map gm cd /run/media/${user}
      map gn cd /run/current-system/
      map gp cd /home/${user}/perso
      map gr cd /home/${user}/repos
      map gt cd /home/${user}/.local/share/Trash/files
      map gu cd /home/${user}/uni
      map gv cd /home/${user}/pictures/videos
      map h updir
      map j down
      map k up
      map l open
      map m
      map md mkdir
      map me edit-new
      map mf touch
      map n search-next
      map p :paste; clear
      map q quit
      map r
      map s visual
      map t
      map ta calc-all-dirsize
      map tc :calcdirsize; show-size
      map tn :set sortby natural; set info; set noreverse
      map ts show-size
      map tt :set sortby time; set info time; set noreverse
      map u unselect
      map v toggle
      map w local-share
      map x cut
      map y copy
      map za
      map zc compress
      map ze extract
      map zh
      map zn
      map zr
      map zs
      map zt
      map ~ cd /home/${user}

      set previewer ${lib.getExe' ctpv "ctpv"}
      map <c-p> $${lib.getExe' ctpv "ctpv"} "$f" | less -R

      &${lib.getExe' ctpv "ctpv"} -s $id
      cmd on-quit %${lib.getExe' ctpv "ctpv"} -e $id
      set cleaner ${lib.getExe' ctpv "ctpvclear"}
      setlocal ~/pictures/ info time
      setlocal ~/pictures/ sortby time
      setlocal ~/pictures/ reverse
      # set sixel true

      on-focus-gained

      vmap s visual-toggle
      vmap o visual-change
      vmap <esc> visual-discard
      ${no-confirm [
        "D"
        "x"
        "y"
        "Y"
        "H"
        "l"
        "ze"
        "zc"
        "w"
        "<c-n>"
      ]}

      &[ "$LF_LEVEL" -eq 1 ] || ${lib.getExe pkgs.lf} -remote "send $id echoerr \"Warning: You're in a nested lf instance!\""
    '';

  hj.xdg.config.files."lf/colors".text = builtins.readFile ./colors;
}
