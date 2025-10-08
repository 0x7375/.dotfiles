{ lib, pkgs, ... }:

{
  xdg.configFile."zsh/set-prompt.sh".text = # bash
    ''
      function is_dirty {
          [[ -n $(${lib.getExe pkgs.git} diff --shortstat 2> /dev/null | ${lib.getExe' pkgs.coreutils-full "tail"} -n1) ]] && ${lib.getExe' pkgs.coreutils-full "echo"} "*"
      }

      function get_git_info() {
          local -r ref=$(${lib.getExe pkgs.git} rev-parse --abbrev-ref HEAD 2>/dev/null)

          local branch
          if [[ $ref == "HEAD" ]]; then
            branch=$(${lib.getExe pkgs.git} rev-parse --short HEAD 2>/dev/null)
          else
            branch=$ref
          fi

          local -r dirty_status="$(is_dirty)"

          if [[ -n $branch ]]; then
              ${lib.getExe' pkgs.coreutils-full "echo"} " $branch$dirty_status"
          fi
      }

      function get_prompt_symbol() {
          if [[ $SHLVL -gt 1 || -n ''${DIRENV_LOADED-} ]]; then
              echo " ::"
          else
              echo " $"
          fi
      }

      function get_ssh_info() {
          if [[ -n ''${SSH_CONNECTION-} ]]; then
              [[ -n ''${ZSH_VERSION-} ]] && echo "%F{yellow}%n%F{green}@%F{cyan}%m:"
          fi
      }

      function set_prompt {
          # Last character is U+202F to navigate previous/next prompt in tmux (check with ga in vim)
          [[ -n ''${ZSH_VERSION-} ]] && PS1='%(?.%f.%F{black}$? )$(get_ssh_info)%F{blue}%~%F{green}$(get_git_info)%F{reset}$(get_prompt_symbol)%f '
          [[ -n ''${BASH_VERSION-} ]] && PS1='$(get_ssh_info)\[\033[34m\]\w\[\033[32m\]$(get_git_info)\[\033[0m\]$(get_prompt_symbol) '
      }
    '';
}
