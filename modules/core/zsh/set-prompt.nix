{ lib, pkgs, ... }:

{
  hj.xdg.config.files."zsh/set-prompt.sh".text = # bash
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

      function get_env() {
          if [[ -n $DIRENV_DIR ]]; then
              msg=direnv
          elif [[ -n $VIRTUAL_ENV ]]; then
              msg=venv
          elif [[ -n $NIX_SHELL_PACKAGES ]]; then
              msg=shell
          elif [[ -n $NIX_BUILD_TOP ]]; then
              msg=develop
          fi

          [[ -n $msg ]] && echo "($msg) "
      }

      function get_prompt_symbol() {
          if [[ $SHLVL -gt ${if pkgs.stdenv.isLinux then "1" else "2"} || -n ''${DIRENV_LOADED-} ]]; then
              echo " ::"
          else
              echo " %%"
          fi
      }

      function get_ssh_info() {
          if [[ -n ''${SSH_CONNECTION-} ]]; then
              [[ -n ''${ZSH_VERSION-} ]] && echo "%F{yellow}%n%F{reset}@%F{cyan}%m:"
              [[ -n ''${BASH_VERSION-} ]] && echo "\[\033[33m\]\u\[\033[0m\]@\[\033[36m\]\h:\[\033[0m\]"
          fi
      }

      function set_prompt {
          # Last character is U+202F to navigate previous/next prompt in tmux (show unicode with ga in vim)
          [[ -n ''${ZSH_VERSION-} ]] && PS1='%(?.%f.%F{red}$? )$(get_ssh_info)%F{reset}$(get_env)%~%F{cyan}$(get_git_info)%F{reset}$(get_prompt_symbol)%f '
          [[ -n ''${BASH_VERSION-} ]] && PS1='\[\033[31m\]$(r=$?; [ $r -ne 0 ] && echo "$r ")\[\033[0m\]$(get_ssh_info)$(get_env)\w\[\033[36m\]$(get_git_info)\[\033[0m\]$(get_prompt_symbol) '
      }
    '';
}
