# In case the system uses a non-POSIX shell, like fish or nushell,
# we want to ensure run also our forked processes in a bash environment.
SHELL="bash"

SEARCH_SNIPPET_KEY="alt-s"
OPEN_SOURCE_KEY="alt-o"
EDIT_SOURCE_KEY="alt-e"
OPEN_HOMEPAGE_KEY="alt-w"
NIX_SHELL_KEY="alt-S"
NIX_PROFILE_KEY="alt-P"
PRINT_PREVIEW_KEY="ctrl-P"

OPENER="xdg-open"
[[ $OSTYPE == darwin* ]] && OPENER="open"

# ========================================
# for debug / development
CMD="${NIX_SEARCH_TV:-nix-search-tv}"

STATE_FILE="/tmp/nix-search-tv-fzf"
# save_state saves the currently displayed index
# to the $STATE_FILE. This file serves as an external script state
# for communication between "print" and "preview" commands

# reset the state
echo "" > $STATE_FILE

SEARCH_SNIPPET_CMD=$'echo "{}"'
# fzf surrounds the matched package with ', trim them
SEARCH_SNIPPET_CMD="$SEARCH_SNIPPET_CMD | tr -d \"'\" "
# if it's multi-index search, then we need to remote the prefix
SEARCH_SNIPPET_CMD="$SEARCH_SNIPPET_CMD | awk '{ if (\$2) { print \$2 } else print \$1 }' "
SEARCH_SNIPPET_CMD="$SEARCH_SNIPPET_CMD | xargs printf \"https://github.com/search?type=code&q=lang:nix+%s\" \$1 "

PACKAGE_NAME="\$(echo '{}' | sed 's:nixpkgs/ ::g')"

NIX_SHELL_CMD="nix shell nixpkgs#$PACKAGE_NAME"
if [ -n "$TMUX" ]; then
  NIX_SHELL_CMD="tmux new-window -n nix-shell-$PACKAGE_NAME -c \$PWD \"$NIX_SHELL_CMD\""
fi

NIX_PROFILE_CMD="nix profile add nixpkgs#$PACKAGE_NAME"

GET_SOURCE_URL="$CMD source \$(cat $STATE_FILE) {} | sed 's|nixos/modules/nixos/modules/|nixos/modules/|g'"

OPEN_SOURCE_CMD="$GET_SOURCE_URL | xargs $OPENER"

EDIT_SOURCE_CMD="
    source_url=\$($GET_SOURCE_URL)

    # strip line number and only keep relative path
    file_path=\$(echo \"\$source_url\" \
        | sed 's|https://github.com/[^/]*/[^/]*/blob/[^/]*/||' \
        | sed 's|https://github.com/[^/]*/[^/]*/tree/[^/]*/||' \
        | sed 's|#L.*||')

    if echo \"\$source_url\" | grep -q 'nix-community/home-manager'; then
        repo_path=\"\$HOME/repos/home-manager\"
    elif echo \"\$source_url\" | grep -q 'nix-darwin/nix-darwin'; then
        repo_path=\"\$HOME/repos/nix-darwin\"
    elif echo \"\$source_url\" | grep -q 'nix-community/nur-combined'; then
        repo_path=\"\$HOME/repos/nur\"
    else
        repo_path=\"\$HOME/repos/nixpkgs\"
    fi

    \$EDITOR \"\$repo_path/\$file_path\"
"

PREVIEW_WINDOW="wrap,40%"
[ "$(tput cols)" -lt 90 ] && PREVIEW_WINDOW="$PREVIEW_WINDOW,up"

exec "$CMD" print | fzf \
  --preview "$CMD preview \$(cat $STATE_FILE) {}" \
  --bind "ctrl-u:preview-up" \
  --bind "ctrl-d:preview-down" \
  --bind "$OPEN_SOURCE_KEY:execute($OPEN_SOURCE_CMD)" \
  --bind "$EDIT_SOURCE_KEY:execute($EDIT_SOURCE_CMD)" \
  --bind "$OPEN_HOMEPAGE_KEY:execute($CMD homepage \$(cat $STATE_FILE) {} | xargs $OPENER)" \
  --bind "$SEARCH_SNIPPET_KEY:execute($SEARCH_SNIPPET_CMD | xargs $OPENER)" \
  --bind "$NIX_SHELL_KEY:become($NIX_SHELL_CMD)" \
  --bind "$NIX_PROFILE_KEY:execute($NIX_PROFILE_CMD)" \
  --bind "$PRINT_PREVIEW_KEY:execute($CMD preview \$(cat $STATE_FILE) {} | less)" \
  --layout reverse \
  --scheme history \
  --border=sharp \
  --preview-border=sharp \
  --preview-window="$PREVIEW_WINDOW"
