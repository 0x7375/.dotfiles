{
  myLib,
  config,
  lib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  sops.secrets."atuin/key" = {
    path = "/home/${config.me.user}/.local/share/atuin/key";
  };
  sops.secrets."atuin/session" = {
    path = "/home/${config.me.user}/.local/share/atuin/session";
  };

  programs.atuin = {
    enable = true;
    daemon.enable = true;
    settings = {
      auto_sync = true;
      store_failed = false;
      sync_frequency = "5m";
      history_filter = [
        "^ .*"
      ];
    };
  };

  xdg.configFile."zsh/.zshrc".text =
    # bash
    ''
      source $ZDOTDIR/atuin-history-arrow.zsh

      export ATUIN_NOBIND="true"
      eval "$(atuin init zsh)"
    '';

  xdg.configFile."zsh/atuin-history-arrow.zsh".text = builtins.readFile ./atuin-history-arrow.zsh;

  xdg.configFile."zsh/widgets.zsh".text =
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

  xdg.configFile."zsh/bindings.zsh".text =
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
