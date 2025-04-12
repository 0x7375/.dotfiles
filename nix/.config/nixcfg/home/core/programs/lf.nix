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
      lib.optionalAttrs (prev.stdenv.hostPlatform.isAarch64) {
        ctpv = prev.ctpv.overrideAttrs (old: {
          CFLAGS = (old.CFLAGS or "") + " -fsigned-char";
        });
      }
    )
  ];

  home.packages =
    [
      pkgs.atool
      pkgs.zip
    ]
    ++ lib.optionals gui [
      ctpv
      pkgs.ueberzugpp
      # pkgs.pistol
      pkgs.poppler_utils
      pkgs.libreoffice
    ];

  xdg.configFile."ctpv/config" = {
    enable = gui;
    text = ''
      preview null .env .git-credentials .wakatime.cfg .keyring {{
          echo "preview disabled"
      }}
    '';
  };

  programs.lf =
    let
      user = config.me.user;
    in
    {
      enable = true;

      extraConfig =
        lib.optionalString gui ''
          &${ctpv}/bin/ctpv -s $id
          cmd on-quit %${ctpv}/bin/ctpv -e $id
          set cleaner ${ctpv}/bin/ctpvclear
        ''
        + ''
          setlocal ~/pictures/ info time
          setlocal ~/pictures/ sortby time
          setlocal ~/pictures/ reverse

          on-focus-gained
        '';
      previewer = lib.mkIf gui {
        keybinding = "<c-p>";
        source = "${ctpv}/bin/ctpv";
      };
      settings = {
        ratios = [
          1
          1
        ];
        # previewer = "pistol";
        shell = "zsh";
        shellopts = "-euy";
        ifs = "\\n";
        filesep = "\\n";
        info = true;
        sortby = "ext";
        hidden = true;
        ignorecase = true;
        icons = false;
        scrolloff = 8;
        tabstop = 4;
      };
      commands = {
        on-focus-gained = # bash
          ''
            :{{
              set cursorparentfmt "\033[7m"
              set cursoractivefmt "\033[7m"
              set cursorpreviewfmt "\033[4m"
            }}'';
        on-focus-lost = # bash
          ''
            :{{
              set cursorparentfmt ""
              set cursoractivefmt ""
              set cursorpreviewfmt ""
            }}
          '';
        calc-all-dirsize = # bash
          ''
            ''${{
                lf -remote "send $id invert"
                lf -remote "send $id calcdirsize"
                lf -remote "send $id unselect"
                lf -remote "send $id show-size"
              }}
          '';
        show-size = ":set sortby size; set info size; set reverse";
        extract = # bash
          ''
            ''${{
              ${pkgs.atool}/bin/aunpack $f
              ${pkgs.trash-cli}/bin/trash $f
            }}
          '';
        compress = # bash
          ''
            %{{
              printf "Archive name: "
              read newa
              if [ -z "$newa" ]; then
                lf -remote "send $id reload"
                return;
              fi
              temp="/tmp/lf-$$"

              echo $temp
              mkdir $temp
              cp -r $fx $temp

              current_dir=$(pwd)
              cd $temp
              ${pkgs.atool}/bin/apack $newa *
              mv $newa "$current_dir"
              cd -
              rm -rf $temp

              lf -remote "send $id unselect"
              lf -remote "send $id select \"$newa\""
                    }}'';
        quit-and-cd = # bash
          ''
            ''${{
              # absolute paths are needed since we can be in a mount point
              LF_CD_FILE=''${LF_CD_FILE:-/dev/null}
              path=$(pwd)
              
              # make sure we are not in a mount point
              while [[ "$path" == *".mnt"* ]]; do
                path=$(${pkgs.coreutils}/bin/dirname "$path")
              done
              
              echo "$path" > "$LF_CD_FILE"
              ${pkgs.lf}/bin/lf -remote "send $id quit"
            }}
          '';
        mount-archive = # bash
          ''
            ''${{
              if ${pkgs.file}/bin/file --mime-type "$f" | grep -qE 'application/zip|application/x-tar|application/x-7z-compressed|application/gzip'; then
                mntdir="''${f}.mnt"
                mkdir -p "$mntdir"
                ${pkgs.archivemount}/bin/archivemount "$f" "$mntdir"
                lf -remote "send $id cd $mntdir"
              fi
            }}
          '';
        su = # bash
          ''
            ''${{
              lf -remote "send $id quit"
              sudo lf
            }}
          '';
        move-to-new-dir = # bash
          ''
            %{{
              printf "Directory name: "
              read newd
              if [[ -z "$newd" ]]; then
                lf -remote "send $id reload"
                return;
              fi

              mkdir -p -- "$newd"
              mv -- $fx "$newd"
            }}
          '';
        bulkrename = # bash
          ''
            ''${{
              export VIMV=1; ${pkgs.vimv-rs}/bin/vimv -- $fs
              lf -remote "send $id load"
              lf -remote "send $id unselect"
            }}
          '';
        mkdir = # bash
          ''
            %{{
              printf "Directory name: "
              read newd
              if [[ -z "$newd" ]]; then
                lf -remote "send $id reload"
                return;
              fi

              mkdir -p "$newd"
              lf -remote "send $id select \"$newd\""
            }}
          '';
        touch = # bash
          ''
            %{{
              printf "File name: "
              read newf
              if [[ -z "$newf" ]]; then
                lf -remote "send $id reload"
                return;
              fi

              touch "$newf"
              lf -remote "send $id select \"$newf\""
            }}
          '';
        edit-new = # bash
          ''
            %{{
              printf "File name: "
              read newf
              if [[ -z "$newf" ]]; then
                lf -remote "send $id reload"
                return;
              fi

              lf -remote "send $id \$touch \"$newf\""
              lf -remote "send $id $\$EDITOR \"$newf\""
            }}
          '';
        follow_link = # bash
          ''
            %{{
              lf -remote "send $id select '$(readlink $f)'"
            }}
          '';
        toggle-executable = # bash
          ''
            ''${{
              [[ -x "$f" ]] && chmod -x "$f" || chmod +x "$f"
              lf -remote 'send reload'
            }}
          '';
        edit = # bash
          ''
            ''${{
              if [ "''${NVIM:-}" ]; then
                lf -remote "send $id open"
              else
                $EDITOR $f
              fi
            }}
          '';
        open = "&mimeo \"$f\"";
        share = "$''${pkgs.curl}/bin/curl -F\"file=@$f\" https://0x0.st | ${pkgs.xsel}/bin/xsel -ib";
        paste-overwrite = # bash
          ''
            %{{
                mode=$(head -1 ~/.local/share/lf/files)
                list=$(${pkgs.gnused}/bin/sed 1d ~/.local/share/lf/files)
                if [ $mode = 'copy' ]; then
                    cp -r $list .
                elif [ $mode = 'move' ]; then
                    mv $list .
                fi
                lf -remote 'send load'
                lf -remote 'send clear'
                lf -remote "send $id reload"
            }}
          '';
        copy-path = # bash
          ''
            ''${{
              echo -en "$fx" | tr ' ' '\n' | ${pkgs.xsel}/bin/xsel -ib
              lf -remote 'send unselect'
              lf -remote 'send echo "Path copied to clipboard"'
            }}
          '';
        external-copy = # bash
          ''
            ''${{
              echo -en "$fx" | sed 's|^|file://|' | tr ' ' '\n' | ${pkgs.xclip}/bin/xclip -i -sel clip -t text/uri-list
              lf -remote 'send unselect'
              lf -remote 'send echo "Files copied to clipboard"'
            }}
          '';
        open-sushi = # bash
          lib.optionalString gui ''
            &{{
              ${pkgs.sushi}/bin/sushi $f

              # forces long loading previews to be centered
              while true; do
                  id=$(${pkgs.i3}/bin/i3-msg -t get_tree | jq -r '.. | select(.window_properties?.class? == "Org.gnome.NautilusPreviewer") | .window? | select(. != null)')
                  if [ ! -z "$id" ]; then
                      ${pkgs.i3}/bin/i3-msg "[id=$id] move position center" > /dev/null
                      break
                  fi
              done
            }}
          '';
      };
      keybindings = {
        "[" = "";
        "]" = "";
        za = "";
        zh = "";
        zn = "";
        zr = "";
        zs = "";
        zt = "";
        "<pgup>" = "";
        "<pgdn>" = "";
        "M" = "";
        "L" = "";
        m = "";
        "\\\"" = "";
        "\\'" = "";
        "t" = "";

        Q = "quit-and-cd";
        f = "find";
        F = "find-back";
        ";" = "find-next";
        "," = "find-prev";
        "/" = "search";
        "?" = "search-back";
        n = "search-next";
        N = "search-prev";
        D = "delete";
        y = "copy";
        Y = "external-copy";
        H = "copy-path";
        C = "clear";
        x = "cut";
        s = "toggle";
        V = "invert";
        v = "invert-below";
        u = "unselect";
        j = "down";
        k = "up";
        J = ":updir; down; open";
        K = ":updir; up; open";
        h = "updir";
        l = "open";
        "<c-u>" = "half-up";
        "<c-d>" = "half-down";
        "<tab>" = "jump-next";
        "<c-o>" = "jump-prev";
        gg = "top";
        G = "bottom";
        "<enter>" = "open";
        q = "quit";
        "." = "set hidden!";
        "`" = "!true";
        tn = ":set sortby natural; set info; set noreverse";
        tt = ":set sortby time; set info time; set noreverse";
        ts = "show-size";
        ta = "calc-all-dirsize";
        tc = ":calcdirsize; show-size";
        A = ":rename; cmd-end";
        c = "push A<c-u>";
        I = ":rename; cmd-home";
        a = ":rename";
        b = "bulkrename";
        d = "";
        r = "";
        "<c-l>" = "mount-archive";
        p = ":paste; clear";
        P = "paste-overwrite";

        "\\$" = "push :$";
        "<space>" = "open-sushi";
        S = "su";
        R = ":source /home/${user}/.config/lf/lfrc; reload";
        "<c-r>" = "redraw";
        e = "edit";
        E = "$sudoedit $f";
        ze = "extract";
        zc = "compress";

        O = lib.optionalString gui "&${pkgs.xdragon}/bin/dragon $fx";
        md = "mkdir";
        mf = "touch";
        me = "edit-new";
        "<c-n>" = "move-to-new-dir";
        "=" = "toggle-executable";
        gL = "follow_link";
        "<c-z>" = "$kill -STOP $PPID";
        W = "share";

        "g/" = "cd /";
        "~" = "cd /home/${user}";
        gd = "cd  /home/${user}/documents";
        gD = "cd /home/${user}/downloads";
        gp = "cd /home/${user}/perso";
        gu = "cd /home/${user}/uni";
        gr = "cd /home/${user}/repos";
        gP = "cd /home/${user}/pictures";
        gv = "cd /home/${user}/pictures/videos";
        gc = "cd /home/${user}/.config";
        ge = config.me.flakeDir;
        gl = "cd /home/${user}/.local";
        gb = "cd /home/${user}/.local/bin";
        gt = "cd /home/${user}/.local/share/Trash/files";
        "g." = "cd /home/${user}/.dotfiles";
        ga = "cd /usr/share/applications";
        gm = "cd /run/media/ayko";
        gn = "cd /run/current-system/";
      };
    };

  xdg.configFile."lf/colors" = {
    enable = true;
    text = # bash
      ''
        # default values from dircolors
        # (entries with a leading # are not implemented in lf)
        # #no     00              # NORMAL
        # fi      00              # FILE
        # #rs     0               # RESET
        # di      01;34           # DIR
        # ln      01;36           # LINK
        # #mh     00              # MULTIHARDLINK
        # pi      40;33           # FIFO
        # so      01;35           # SOCK
        # #do     01;35           # DOOR
        # bd      40;33;01        # BLK
        # cd      40;33;01        # CHR
        # or      40;31;01        # ORPHAN
        # #mi     00              # MISSING
        # su      37;41           # SETUID
        # sg      30;43           # SETGID
        # #ca     30;41           # CAPABILITY
        # tw      30;42           # STICKY_OTHER_WRITABLE
        # ow      34;42           # OTHER_WRITABLE
        # st      37;44           # STICKY
        # ex      01;32           # EXEC

        # default values from lf (with matching order)
        # ln      01;36   # LINK
        # or      31;01   # ORPHAN
        # tw      01;34   # STICKY_OTHER_WRITABLE
        # ow      01;34   # OTHER_WRITABLE
        # st      01;34   # STICKY
        # di      01;34   # DIR
        # pi      33      # FIFO
        # so      01;35   # SOCK
        # bd      33;01   # BLK
        # cd      33;01   # CHR
        # su      01;32   # SETUID
        # sg      01;32   # SETGID
        # ex      01;32   # EXEC
        # fi      00      # FILE

        # file types (with matching order)
        ln      01;36   # LINK
        or      31;01   # ORPHAN
        tw      34      # STICKY_OTHER_WRITABLE
        ow      34      # OTHER_WRITABLE
        st      01;34   # STICKY
        di      01;34   # DIR
        pi      33      # FIFO
        so      01;35   # SOCK
        bd      33;01   # BLK
        cd      33;01   # CHR
        su      01;32   # SETUID
        sg      01;32   # SETGID
        ex      01;32   # EXEC
        fi      00      # FILE

        # archives or compressed (dircolors defaults)
        *.tar   01;31
        *.tgz   01;31
        *.arc   01;31
        *.arj   01;31
        *.taz   01;31
        *.lha   01;31
        *.lz4   01;31
        *.lzh   01;31
        *.lzma  01;31
        *.tlz   01;31
        *.txz   01;31
        *.tzo   01;31
        *.t7z   01;31
        *.zip   01;31
        *.z     01;31
        *.dz    01;31
        *.gz    01;31
        *.lrz   01;31
        *.lz    01;31
        *.lzo   01;31
        *.xz    01;31
        *.zst   01;31
        *.tzst  01;31
        *.bz2   01;31
        *.bz    01;31
        *.tbz   01;31
        *.tbz2  01;31
        *.tz    01;31
        *.deb   01;31
        *.rpm   01;31
        *.jar   01;31
        *.war   01;31
        *.ear   01;31
        *.sar   01;31
        *.rar   01;31
        *.alz   01;31
        *.ace   01;31
        *.zoo   01;31
        *.cpio  01;31
        *.7z    01;31
        *.rz    01;31
        *.cab   01;31
        *.wim   01;31
        *.swm   01;31
        *.dwm   01;31
        *.esd   01;31

        # image formats (dircolors defaults)
        *.jpg   01;35
        *.jpeg  01;35
        *.mjpg  01;35
        *.mjpeg 01;35
        *.gif   01;35
        *.bmp   01;35
        *.pbm   01;35
        *.pgm   01;35
        *.ppm   01;35
        *.tga   01;35
        *.xbm   01;35
        *.xpm   01;35
        *.tif   01;35
        *.tiff  01;35
        *.png   01;35
        *.jfif  01;35
        *.ico   01;35
        *.svg   01;35
        *.svgz  01;35
        *.mng   01;35
        *.pcx   01;35
        *.mov   01;35
        *.mpg   01;35
        *.mpeg  01;35
        *.m2v   01;35
        *.mkv   01;35
        *.webm  01;35
        *.ogm   01;35
        *.mp4   01;35
        *.m4v   01;35
        *.mp4v  01;35
        *.vob   01;35
        *.qt    01;35
        *.nuv   01;35
        *.wmv   01;35
        *.asf   01;35
        *.rm    01;35
        *.rmvb  01;35
        *.flc   01;35
        *.avi   01;35
        *.fli   01;35
        *.flv   01;35
        *.gl    01;35
        *.dl    01;35
        *.xcf   01;35
        *.xwd   01;35
        *.yuv   01;35
        *.cgm   01;35
        *.emf   01;35
        *.ogv   01;35
        *.ogx   01;35

        # audio formats (dircolors defaults)
        *.aac   00;36
        *.au    00;36
        *.flac  00;36
        *.m4a   00;36
        *.mid   00;36
        *.midi  00;36
        *.mka   00;36
        *.mp3   00;36
        *.mpc   00;36
        *.ogg   00;36
        *.ra    00;36
        *.wav   00;36
        *.oga   00;36
        *.opus  00;36
        *.spx   00;36
        *.xspf  00;36

        # compilation files
        *.aux   00;37
        *.log   00;37
        *.out   00;37
        *.toc   00;37
        *.class 00;37
        *.o     00;37
        *.pyc   00;37
      '';
  };
}
