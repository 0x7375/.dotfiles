{ pkgs, ... }:

{
  home.file.".config/zsh/set-prompt.sh" = {
    force = true;
    mutable = true;
    text = # bash
      ''
        function is_dirty {
            [[ $(${pkgs.git}/bin/git diff --shortstat 2> /dev/null | ${pkgs.coreutils-full}/bin/tail -n1) != "" ]] && ${pkgs.coreutils-full}/bin/echo "*"
        }

        function get_git_info() {
            local ref=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null)

            if [[ "$ref" == "HEAD" ]]; then
              branch=$(${pkgs.git}/bin/git rev-parse --short HEAD 2>/dev/null)
            else
              branch=$ref
            fi

            dirty_status="$(is_dirty)"

            if [[ $branch != "" ]]; then
                ${pkgs.coreutils-full}/bin/echo " $branch$dirty_status"
            fi
        }

        function get_prompt_symbol() {
            if [[ $SHLVL -gt 1 || -n $DIRENV_LOADED ]]; then
                echo " ~"
            else
                echo " $"
            fi
        }

        function get_ssh_info() {
            if [[ -n $SSH_CONNECTION ]]; then
                echo "%F{yellow}%n%F{green}@%F{cyan}%m:"
            fi
        }

        function set_prompt {
            # Last character is U+202F to navigate previous/next prompt in tmux (check with ga in vim)
            PS1='$(get_ssh_info)%F{blue}%~%F{green}$(get_git_info)%f$(get_prompt_symbol) '
        }
      '';
  };
}
