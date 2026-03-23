#!/usr/bin/env bash
# hypr-autogroup — hide groupbar on single-window workspaces
# assumes: windowrulev2 = group set, class:.*

SOCK="${XDG_RUNTIME_DIR:-/tmp}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
dispatch() { hyprctl dispatch "$@" > /dev/null; }

handle_ws() {
  local ws=$1
  local all
  # count all windows including hidden group tabs
  all=$(hyprctl clients -j | jq -c --argjson w "$ws" '[.[] | select(.workspace.id==$w)]')
  local count
  count=$(echo "$all" | jq 'length')

  if ((count <= 1)); then
    # dissolve group so groupbar disappears for lone windows
    local addr
    addr=$(echo "$all" | jq -r 'first | select(.grouped|length>0) | .address // empty')
    if [[ -n $addr ]]; then
      dispatch focuswindow "address:$addr"
      dispatch togglegroup
    fi
    return
  fi

  # only visible windows can be ungrouped; hidden ones are already group tabs
  local visible
  visible=$(echo "$all" | jq -c '[.[] | select(.hidden==false)]')
  local anchor
  anchor=$(echo "$visible" | jq -r 'first(.[] | select(.grouped|length>0)) | .address // empty')
  mapfile -t ungrouped < <(echo "$visible" | jq -r '[.[] | select(.grouped|length==0)] | .[].address')
  [[ ${#ungrouped[@]} -eq 0 ]] && return

  # no existing group — promote first ungrouped window as anchor
  if [[ -z $anchor ]]; then
    anchor=${ungrouped[0]}
    ungrouped=("${ungrouped[@]:1}")
    dispatch focuswindow "address:$anchor"
    dispatch togglegroup
  fi

  for addr in "${ungrouped[@]}"; do
    dispatch focuswindow "address:$addr"
    # hyprctl always exits 0 so re-query state to confirm merge succeeded
    for dir in l r u d; do
      dispatch moveintogroup $dir
      local g
      g=$(hyprctl clients -j | jq -r --arg a "$addr" '.[] | select(.address==$a) | .grouped | length')
      ((g > 0)) && break
    done
  done
}

socat -U - "UNIX-CONNECT:$SOCK" | while IFS= read -r line; do
  event=${line%%>>*}
  data=${line##*>>}
  case $event in
    openwindow | movewindow)
      addr=${data%%,*}
      ws=$(hyprctl clients -j | jq -r --arg a "0x$addr" '.[] | select(.address==$a) | .workspace.id')
      [[ -n $ws && $ws != null ]] && handle_ws "$ws"
      ;;
    closewindow)
      # window is already gone — scan all workspaces left with a single window
      hyprctl workspaces -j | jq -r '.[] | select(.windows==1) | .id' | while read -r ws; do
        handle_ws "$ws"
      done
      ;;
  esac
done
