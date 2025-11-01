{
  pkgs,
  config,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."atuin/key" = {
    path = "/home/${config.me.user}/.local/share/atuin/key";
    owner = config.me.user;
  };
  sops.secrets."atuin/session" = {
    path = "/home/${config.me.user}/.local/share/atuin/session";
    owner = config.me.user;
  };

  packages = [ pkgs.atuin ];

  hj.xdg.config.files."atuin/config.toml" = {
    generator = (pkgs.formats.toml { }).generate "atuin-config.toml";
    value = {
      auto_sync = true;
      daemon = {
        enabled = true;
        systemd_socket = true;
      };
      store_failed = false;
      sync_frequency = "5m";
      history_filter = [
        "^ .*"
        "lf"
        "nst"
        "^v$"
      ];
    };
  };

  systemd.user.services.atuin-daemon = {
    description = "Atuin daemon";
    requires = [ "atuin-daemon.socket" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.atuin} daemon";
      Restart = "on-failure";
      RestartSteps = 3;
      RestartMaxDelaySec = 6;
    };
  };

  systemd.user.sockets.atuin-daemon = {
    description = "Atuin daemon socket";
    wantedBy = [ "sockets.target" ];

    socketConfig = {
      ListenStream = "%t/atuin.sock";
      SocketMode = "0600";
      RemoveOnStop = true;
    };
  };

  hj.xdg.config.files."zsh/.zshrc".text =
    # bash
    ''
      source $ZDOTDIR/atuin-history-arrow.zsh

      export ATUIN_NOBIND="true"
      eval "$(atuin init zsh)"
    '';

  hj.xdg.config.files."zsh/atuin-history-arrow.zsh".text =
    builtins.readFile ./atuin-history-arrow.zsh;

  hj.xdg.config.files."zsh/widgets.zsh".text =
    lib.mkAfter
      # bash
      ''
        fzf-atuin-history-widget() {
            local selected num
            setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

            local atuin_opts="--cmd-only --limit 50000"
            local fzf_opts=(
                --height=40%
                --tac
                "-n2..,.."
                --tiebreak=index
                "--query=''${LBUFFER}"
                --reverse
                "--padding=1"
            )

            selected=$(eval "atuin search ''${atuin_opts}" | fzf "''${fzf_opts[@]}")
            local ret=$?
            if [[ -n $selected ]]; then
                LBUFFER="''${selected}"
            fi
            zle reset-prompt
            return $ret
        }
        zle -N fzf-atuin-history-widget

        alias t='atuin search --limit 1 --format "{duration}"'
      '';

  hj.xdg.config.files."zsh/bindings.zsh".text =
    lib.mkAfter
      # bash
      ''
        if atuin doctor 2>&1 | grep -q '"sync": null'; then
          bindkey '^R' fzf-atuin-history-widget

          bindkey '^[[A' atuin-history-up
          bindkey '^[[B' atuin-history-down
          bindkey '^P' atuin-history-up
          bindkey '^N' atuin-history-down
        fi
      '';
}
