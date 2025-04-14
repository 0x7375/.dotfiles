{ config, lib, ... }:

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
      sync_frequency = "5m";
      flags = [
        "--disable-up-arrow"
        "--disable-ctrl-r"
      ];
    };
  };

  xdg.configFile."zsh/widgets.zsh".text =
    lib.mkAfter
      # bash
      ''
        export ATUIN_NOBIND=1
        eval "$(atuin init zsh)"
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
            )

            selected=$(
                eval "atuin search ''${atuin_opts}" |
                    fzf "''${fzf_opts[@]}"
            )
            local ret=$?
            if [ -n "$selected" ]; then
                LBUFFER+="''${selected}"
            fi
            zle reset-prompt
            return $ret
        }
        zle -N fzf-atuin-history-widget
      '';
}
