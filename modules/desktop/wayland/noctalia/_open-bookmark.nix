pkgs:
pkgs.writeShellApplication {
  name = "open-bookmark";
  runtimeInputs = with pkgs; [
    my.noctalia
    coreutils
    xdg-utils
    curl
    jq
    procps
  ];
  text = ''
    add_tabs() {
      local decoded
      decoded=$(python3 -c '
    import sys, html
    for line in sys.stdin:
        print(html.unescape(line.rstrip("\n")))
    ')
      while IFS=';' read -r ttl url; do
        [[ -z "$url" ]] && continue
        tabs["$ttl: $url"]="$url"
      done <<< "$decoded"
    }

    file="$HOME/notes/bookmarks.csv"
    [[ ! -f $file ]] && exit

    declare -A bookmarks
    while IFS=',' read -r _ url title tags; do
      label="$title $tags"
      bookmarks["$label"]="$url"
    done < <(tac "$file")

    selection=$(printf '%s\n' "''${!bookmarks[@]}" \
      | noctalia dmenu -p "Open or create a bookmark..." -g bookmark)
    [[ -z "$selection" ]] && exit

    if [[ -n "''${bookmarks[$selection]+x}" ]]; then
      xdg-open "''${bookmarks[$selection]}"
      exit
    fi

    # No existing bookmark picked, creating a new one
    title="''${selection//,/;}"

    declare -A tabs

    curl -s http://localhost:9800/json 2>/dev/null \
      | jq -r '.[] | select(.type=="page") | "\(.title);\(.url)"' \
      | add_tabs

    if pgrep -x zen >/dev/null 2>&1; then
      python3 ${import ./_list-firefox-tabs.nix pkgs} | add_tabs
    fi

    url_input=$(printf '%s\n' "''${!tabs[@]}" \
      | noctalia dmenu -g link -p "URL (pick a tab or type one)")
    [[ -z "$url_input" ]] && exit
    url="''${tabs[$url_input]:-$url_input}"

    existing_tags=$(awk -F',' '{print $4}' "$file" \
      | grep -oP ':\K[^:]+(?=:)' \
      | sort -u)
    tags=$(printf '%s\n' "$existing_tags" \
      | noctalia dmenu -g tag -p "Tags (e.g. TAG or TAG:TAG2)")
    if [[ -n "$tags" && "$tags" != :*: ]]; then
      tags=":''${tags}:"
    fi

    printf '%s,%s,%s,%s\n' "$(date +%F)" "$url" "$title" "$tags" >> "$file"
  '';
}
