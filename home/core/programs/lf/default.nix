{
  myLib,
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
    (final: prev: {
      xdg-desktop-portal-termfilechooser =
        prev.xdg-desktop-portal-termfilechooser.overrideAttrs
          (old: rec {
            version = "caf24e77189f500b6a27ef502ef01d3a96196510";
            src = pkgs.fetchFromGitHub {
              owner = old.src.owner;
              repo = old.src.repo;
              rev = "${version}";
              sha256 = "2A+y6twdfLl/Fy4Feop3tMGfTytxX80acTrFQ56kjS4=";
            };
          });

      file-handler = pkgs.stdenv.mkDerivation {
        name = "file-handler";
        src = ./.;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          dbus.dev
          pkg-config
        ];

        buildPhase = ''
          gcc -o file-handler $src/file-handler.c $(pkg-config --cflags --libs dbus-1)
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp file-handler $out/bin
        '';
      };
    })
  ];

  home.packages = [
    pkgs.ouch
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
      preview null .env .git-credentials .keyring {{
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
        let
          confirm-key = "s";
          no-confirm =
            keys: lib.concatStringsSep "\n" (map (key: "vmap ${key} push ${confirm-key}${key}") keys);
        in
        lib.optionalString gui
          # bash
          ''
            &${ctpv}/bin/ctpv -s $id
            cmd on-quit %${ctpv}/bin/ctpv -e $id
            set cleaner ${ctpv}/bin/ctpvclear
          ''
        +
          # bash
          ''
            setlocal ~/pictures/ info time
            setlocal ~/pictures/ sortby time
            setlocal ~/pictures/ reverse

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

            &[ "$LF_LEVEL" -eq 1 ] || lf -remote "send $id echoerr \"Warning: You're in a nested lf instance!\""
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
        on-cd = # bash
          ''
            &{{
              if [ -d .git ] || [ -f .git ]; then
                  branch="$(git branch --show-current 2>/dev/null)" || true
                  fmt="\033[32;1m%u@%h\033[0m:\033[34;1m%w\033[0m\033[32;1m git:$branch\033[0m"
              else
                  fmt="\033[32;1m%u@%h\033[0m:\033[34;1m%d\033[0m\033[1m%f\033[0m"
              fi
              lf -remote "send $id set promptfmt \"$fmt\""
            }}'';
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
              set -f
              ${pkgs.ouch}/bin/ouch decompress $fx
              ${pkgs.trash-cli}/bin/trash $f
            }}
          '';
        compress = # bash
          ''
            %{{
              default_name="$(basename $(echo "$fx" | head -n1))"
              default_name="''${default_name%%.*}.zip"
              
              printf "Archive name (default: $default_name): "
              read new_name
              if [[ -z $new_name ]]; then
                new_name=$default_name
              fi

              ${pkgs.ouch}/bin/ouch compress $(realpath --relative-to="$(pwd)" $fx) $new_name 

              lf -remote "send $id unselect"
              lf -remote "send $id select \"$new_name\""
            }}'';
        quit-and-cd = # bash
          ''
            ''${{
              # absolute paths are needed since we can be in a mount point
              LF_CD_FILE=''${LF_CD_FILE:-/dev/null}
              path=$(pwd)
              
              # make sure we are not in a mount point
              while [[ $path == *".mnt"* ]]; do
                path=$(${pkgs.coreutils}/bin/dirname "$path")
              done
              
              echo "$path" > "$LF_CD_FILE"
              ${pkgs.lf}/bin/lf -remote "send $id quit"
            }}
          '';
        mount-archive = # bash
          ''
            ''${{
              if ${pkgs.file}/bin/file --mime-type "$f" | grep -qE 'application/zip|application/x-tar|application/x-7z-compressed|application/octet-stream|application/gzip'; then
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
              if [[ -z $newd ]]; then
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
              if [[ -z $newd ]]; then
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
              if [[ -z $newf ]]; then
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
              if [[ -z $newf ]]; then
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
              [[ -x $f ]] && chmod -x "$f" || chmod +x "$f"
              lf -remote 'send reload'
            }}
          '';
        edit = # bash
          ''
            ''${{
              if [[ ''${NVIM:-} ]]; then
                lf -remote "send $id open"
              else
                $EDITOR $f
              fi
            }}
          '';
        open = "&mimeopen \"$f\" > /dev/null 2>&1";

        online-share = "$''${pkgs.curl}/bin/curl -F\"file=@$f\" https://0x0.st | ${pkgs.xsel}/bin/xsel -ib";
        local-share = # bash
          ''
            ''${{
              source ~/.config/zsh/widgets.zsh
              out=$(ks $fx)
              device=$(echo "$out" | head -n 1 | cut -d\  -f3)
              count=$(echo "$out" | tail -n +2 | wc -l)

              lf -remote 'send unselect'
              lf -remote "send echo '$count Files sent to $device'"
            }}
          '';
        paste-overwrite = # bash
          ''
            %{{
                mode=$(head -1 ~/.local/share/lf/files)
                list=$(${pkgs.gnused}/bin/sed 1d ~/.local/share/lf/files)
                if [[ $mode == "copy" ]]; then
                    cp -r $list .
                elif [[ $mode == "move" ]]; then
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
        s = "visual";
        v = "invert";
        u = "unselect";
        j = "down";
        k = "up";
        J = ":updir; down; open";
        K = ":updir; up; open";
        h = "updir";
        l = "open";
        "<space>" = "$mimeopen --ask $f";

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

        "<c-p>" = if gui then "$less -R $f" else "";

        "\\$" = "push :$";
        S = "su";
        R = ":source /home/${user}/.config/lf/lfrc; reload";
        "<c-r>" = "redraw";
        e = "edit";
        E = "$sudoedit $f";
        ze = "extract";
        zc = "compress";

        O = lib.optionalString gui "&${pkgs.xdragon}/bin/xdragon $fx";
        md = "mkdir";
        mf = "touch";
        me = "edit-new";
        "<c-n>" = "move-to-new-dir";
        "=" = "toggle-executable";
        gL = "follow_link";
        "<c-z>" = "$kill -STOP $PPID";
        w = "local-share";
        W = "online-share";

        "g/" = "cd /";
        "~" = "cd /home/${user}";
        gd = "cd  /home/${user}/documents";
        gD = "cd /home/${user}/downloads";
        gp = "cd /home/${user}/perso";
        gu = "cd /home/${user}/uni";
        gr = "cd /home/${user}/repos";
        gR = "cd /run/user/${toString config.me.uid}";
        gP = "cd /home/${user}/pictures";
        gv = "cd /home/${user}/pictures/videos";
        gc = "cd /home/${user}/.config";
        ge = "cd " + config.me.flakeDir;
        gl = "cd /home/${user}/.local";
        gb = "cd /home/${user}/.local/bin";
        gt = "cd /home/${user}/.local/share/Trash/files";
        ga = "cd /usr/share/applications";
        gm = "cd /run/media/ayko";
        gn = "cd /run/current-system/";
        gN = "cd /nix/store";
      };
    };

  xdg.configFile."lf/colors".text = builtins.readFile ./colors;

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text =
    let
      env = pkgs.buildEnv {
        name = "lf-wrapper-env";
        paths = with pkgs; [
          lf
          gnused
          coreutils
          bashInteractive
          zsh
          git
        ];
      };
    in
    # ini
    ''
      [filechooser]
      env=PATH='${env}/bin'
      env=TERMCMD='${pkgs.alacritty}/bin/alacritty -T filechooser -e'
      cmd='${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/lf-wrapper.sh'
      default_dir=${config.xdg.userDirs.download}
    '';

  systemd.user.services."file-handler" = {
    Service.ExecStart = "${pkgs.file-handler}/bin/file-handler";
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = # ini
    ''
      [D-BUS Service]
      Name=org.freedesktop.FileManager1
      Exec=${pkgs.file-handler}/bin/file-handler
    '';
}
