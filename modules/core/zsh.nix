{
  flake.modules.generic.core =
    {
      lib,
      config,
      options,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = false;
      };

      hj.xdg.config.files."zsh/.zshrc".text =
        # zsh
        ''
          source /etc/profile

          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
          export ZSH_AUTOSUGGEST_STRATEGY=(history)
          export ZSH_AUTOSUGGEST_USE_ASYNC=1

          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
          source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

          source $ZDOTDIR/completion.zsh
          source $ZDOTDIR/opts.zsh
          source $ZDOTDIR/widgets.zsh
          source $ZDOTDIR/bindings.zsh
          source $ZDOTDIR/set-prompt.sh
          source $ZDOTDIR/global-aliases.zsh
          source $ZDOTDIR/longcmd-notify.zsh 2>/dev/null
          source $ZDOTDIR/history.zsh

          zle_highlight=('paste:none')

          # allow any character to resume terminal after ctrl+s
          stty ixany

          set_prompt
        '';

      hj.xdg.config.files."zsh/global-aliases.zsh".text = # zsh
        ''
          alias -g @nout="> /dev/null"
          alias -g @nerr="2> /dev/null"
          alias -g @null="> /dev/null 2>&1"
          alias -g @d="@null & disown"

          _smart_copy() {
            local data=$(cat)
            if [[ -n "$SSH_TTY" ]]; then
              printf '\033]52;c;%s\a' "$(printf '%s' "$data" | base64 | tr -d '\n')" > "$SSH_TTY"
            else
              printf '%s' "$data" | ${if (options ? me.desktop) then config.me.desktop.copy else "/dev/null"}
            fi
          }

          alias -g @copy="| _smart_copy"
        '';

      hj.xdg.config.files."zsh/history.zsh".text = # zsh
        ''
          hist_dir="$XDG_STATE_HOME"/zsh
          mkdir -p "$hist_dir" > /dev/null

          export HISTFILE="$hist_dir"/history 

          # generate a unique ID once per machine to avoid
          # syncthing conflicts on new install (darwin doesn't have a /etc/machine-id)
          id_file="$hist_dir/machine_id"
          [[ ! -f "$id_file" ]] && uuidgen > "$id_file"
          machine_id=$(< "$id_file")

          HOSTFILE="$hist_dir/$(hostname)_''${machine_id}_history"
          touch "$HISTFILE" "$HOSTFILE"

          HISTSIZE=5000000
          SAVEHIST=5000000

          merge_histories() {
            local lock_dir="$hist_dir/.merge.lock"
            # A merge is going on, quit
            command mkdir "$lock_dir" >/dev/null 2>&1 || return 0

            {
              # Keep only the most recent occurrence of each command across all history files, sorted by timestamp
              # Replace every newline with a special char so sort and awk work, and add newlines back later
              perl -0777 -pe 's/\\\n/\x01/g' "$hist_dir"/*_history 2>/dev/null \
                | sort -t':' -k2,2n \
                | awk '
                    {
                      if (match($0, /^: [0-9]+:[0-9]+;/)) cmd = substr($0, RLENGTH + 1)
                      else cmd = $0
                      lines[NR]=$0; cmds[NR]=cmd; seen[cmd]=NR
                    }
                    END { for (i=1;i<=NR;i++) if (seen[cmds[i]]==i) print lines[i] }
                  ' \
                | perl -pe 's/\x01/\\\n/g' > "$HISTFILE"
            } always {
              rmdir "$lock_dir"
            }
          }

          zshaddhistory() {
            emulate -L zsh
            _HISTLINE=''${1%%$'\n'}
            return 2
          }

          precmd() {
            local -i rc=$?
            emulate -L zsh

            # command did not fail, is not empty, does not start with space, is not a single word
            if (( (rc == 0 || rc == 130 || rc == 3 || rc == 4 || rc == 139) && ''${+_HISTLINE} && $#_HISTLINE )) \
              && [[ ! $_HISTLINE =~ '^ ' ]] \
              && [[ ! $_HISTLINE =~ '^[a-zA-Z0-9_-]+$' ]]; then

              # Escape newlines so they're conserved in history properly
              # Ignore commands ending with a odd number of backslashes
              local trailing_bs="''${_HISTLINE##*[^\\]}"
              if ((''${#trailing_bs} % 2 == 0 )); then
                builtin print -r -- ": $(date +%s):0;''${_HISTLINE//$'\n'/$'\\\n'}" >> "$HOSTFILE"
              fi
            fi
            
            merge_histories &!
            unset _HISTLINE
            return $rc
          }
          merge_histories
        '';

      hj.xdg.config.files."zsh/opts.zsh".text = # zsh
        ''
          setopt globdots
          setopt nobeep
          setopt menucomplete
          setopt interactivecomments
          setopt histignorespace
          setopt histignoredups
          setopt banghist
          setopt histignorealldups
          setopt histfindnodups
          setopt prompt_subst
          setopt autopushd
          setopt pushdsilent
        '';

      hj.xdg.config.files."zsh/set-prompt.sh".text = # zsh
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
              if [[ -n $VIRTUAL_ENV ]]; then
                  msg=venv
              elif [[ -n $DIRENV_LOADED ]]; then
                  msg=direnv
              elif [[ -n $NIX_SHELL_PACKAGES ]]; then
                  local pkgs=$(echo "$NIX_SHELL_PACKAGES" | tr ' ' '\n' | sed 's/-[0-9].*//' | sort -u)
                  local count=$(echo "$pkgs" | wc -l)
                  if [ "$count" -le 3 ]; then
                      msg=$(echo "$pkgs" | paste -sd, -)
                  else
                      local first=$(echo "$pkgs" | head -3 | paste -sd, -)
                      msg="$first+$((count - 3))"
                  fi
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
              if [[ -n ''${ZSH_VERSION-} ]]; then
                PS1='%(?.%f.%F{red}$? )$(get_ssh_info)%F{reset}$(get_env)%~%F{cyan}$(get_git_info)%F{reset}$(get_prompt_symbol)%f '
              elif [[ -n ''${BASH_VERSION-} ]]; then
                PS1='\[\033[31m\]$(r=$?; [ $r -ne 0 ] && printf "$r ")\[\033[0m\]$(get_ssh_info)$(get_env)\w\[\033[36m\]$(get_git_info)\[\033[0m\]$(get_prompt_symbol) '
              fi
          }
        '';

      hj.xdg.config.files."zsh/widgets.zsh".text = # zsh
        ''
          function lf() {
              export LF_CD_FILE=/var/tmp/.lfcd-$$

              command ${lib.getExe pkgs.lf} "$@"

              # remove mounted archives
              mount | ${lib.getExe' pkgs.gawk "awk"} '/archivemount/ { print $3 }' | while read -r mntdir
              do
                  if [[ "$OSTYPE" == "darwin"* ]]; then
                      umount "$mntdir"
                  else
                      umount "$mntdir" -l
                  fi
                  rmdir "$mntdir" 2>/dev/null
              done

              # handle cd to last directory
              if [[ -s $LF_CD_FILE ]]; then
                  cd "$(< "$LF_CD_FILE")"
                  \rm "$LF_CD_FILE"
              fi
              unset LF_CD_FILE
          }
          # don't use a widget because of https://github.com/gokcehan/lf/issues/585

          autoload -U edit-command-line
          zle -N edit-command-line

          fzf-file-widget() {
            local -r selected=$(${lib.getExe pkgs.fd} . --min-depth 2 --hidden \
              | ${lib.getExe pkgs.fzf} --height 40% --reverse --no-separator --query="''${LBUFFER##* }")

            if [[ -n $selected ]]; then
              LBUFFER="''${LBUFFER% *} $selected"
              [[ $LBUFFER == " $selected" ]] && LBUFFER="$selected"
            fi
            zle reset-prompt
          }
          zle -N fzf-file-widget

          fzf-history-widget() {
            # Fzf splits on \x00 so we can draw multiline commands properly
            local -r selected=$(fc -rl 1 \
              | perl -0777 -pe 's/\n/\x00/g; s/\\n/\n/g' \
              | ${lib.getExe pkgs.fzf} --read0 --height 40% --reverse --no-separator --query="$LBUFFER")
            
            if [[ -n $selected ]]; then
              local num=$(echo "$selected" | awk '{print $1}')
              zle vi-fetch-history -n $num
            fi
            zle reset-prompt
          }
          zle -N fzf-history-widget

          ks() {
            if ! command -v kdeconnect-cli &> /dev/null; then
              echo "kdeconnect is not installed."
              return 1
            fi

            local device=$(kdeconnect-cli --list-devices --name-only | ${lib.getExe pkgs.fzf} --height 40% --reverse)

            if [ -z "$device" ]; then
              return 1
            fi
            
            echo "Sharing with $device"
            if [[ -z $1 ]]; then
              kdeconnect-cli --send-clipboard -n "$device"
            elif [[ -f $1 || "$1" =~ ^https?:// ]]; then
              kdeconnect-cli --share "$@" -n "$device"
            else
              kdeconnect-cli --share-text "$1" -n "$device"
            fi
          }
        '';

      hj.xdg.config.files."zsh/completion.zsh".text = # zsh
        ''
          mkdir -p $XDG_CACHE_HOME/zsh > /dev/null
          autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump

          zmodload zsh/complist

          # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
          zstyle ':completion:*' menu no

          zstyle ':fzf-tab:*' use-fzf-default-opts yes
          zstyle ':fzf-tab:*' fzf-flags --no-separator

          zstyle ':fzf-tab:*' switch-group 'alt-h' 'alt-l'
          zstyle ':fzf-tab:*' fzf-bindings 'ctrl-l:toggle+down'
          zstyle ':fzf-tab:*' continuous-trigger 'ctrl-i'

          zstyle ':completion:*:descriptions' format '[%d]'

          zstyle ':completion:*' use-ip true

          # zstyle ':completion:*' menu yes select
          # zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

          # zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
          # zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
          # zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
          # zstyle ':completion:*' group-name '''

          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
        '';

      hj.xdg.config.files."zsh/bindings.zsh".text = # zsh
        ''
          bindkey -e

          bindkey '\ev' edit-command-line

          bindkey '^G' fzf-history-widget
          bindkey '^T' fzf-file-widget

          bindkey -s '^O' "lf^M"

          export KEYTIMEOUT=1  

          # shift-tab in completion
          bindkey '^[[Z' reverse-menu-complete

          bindkey -M menuselect '^P' up-line-or-history
          bindkey -M menuselect '^N' down-line-or-history

          bindkey -M menuselect '^[' undo

          bindkey -M menuselect '/' history-incremental-search-forward

          bindkey '^P' history-substring-search-up
          bindkey '^N' history-substring-search-down

          HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
          HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=
          HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=
        '';
    };

  flake.modules.nixos.core = {
    persistUser.directories = [
      ".cache/zsh"
      ".local/state/zsh"
    ];
  };

  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    let
      inherit (lib) getExe getExe';
    in
    {
      hj.xdg.config.files."zsh/longcmd-notify.zsh".text =
        let
          activeWindow = lib.optionalString pkgs.stdenv.isLinux "${getExe pkgs.lswt} -j | jq '.toplevels[] | select(.activated == true).title'";
        in
        # zsh
        ''
          [[ -z $WAYLAND_DISPLAY ]] && return 0

          time_threshold=10
          time_taken=0
          cmd=""
          start_window_id=""

          long_command_alert_start() {
            time_taken=$(${getExe' pkgs.coreutils "date"} +%s)
            cmd="$1"
            start_window_id=$(${activeWindow})
          }

          long_command_alert_end() {
            if [[ $time_taken -gt 0 ]]; then
              local duration=$(($(${getExe' pkgs.coreutils "date"} +%s) - $time_taken))
              if [[ $duration -gt $time_threshold ]]; then
                if ! original_window_is_focused; then
                  duration=$(get_duration "$duration")
                  ${getExe pkgs.my.notify} -i brand-powershell "Shell" "Command done: $duration $cmd"
                fi
              fi
              time_taken=0
            fi
          }

          get_duration() {
            local duration=$1
            if [[ $duration -gt 3600 ]]; then
              duration=$((duration / 3600))
              minutes=$((duration % 60))
              duration="''${duration}h''${minutes:+''${minutes}m}"
            elif [[ $duration -ge 60 ]]; then
              duration=$((duration / 60))
              seconds=$((duration % 60))
              duration="''${duration}m''${seconds:+''${seconds}s}"
            else
              duration="''${duration}s"
            fi
            echo "$duration"
          }

          original_window_is_focused() {
            local current_window_id=$(${activeWindow})
            [[ $current_window_id == $start_window_id ]]
          }

          autoload -U add-zsh-hook
          add-zsh-hook preexec long_command_alert_start
          add-zsh-hook precmd long_command_alert_end
        '';
    };
}
