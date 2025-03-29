{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "merge-zsh";
  runtimeInputs = [ ];
  text = ''
    FOLDER_PATH="$1"
    FILE_PATH="$2"
    FULL_PATH="$FOLDER_PATH/$FILE_PATH"

    if [[ "$FILE_PATH" != "history" ]]; then
      exit 1
    fi

    TEMP_DIR=$(mktemp -d)
    INCOMING_FILE="$TEMP_DIR/incoming_history"
    EXISTING_FILE="$TEMP_DIR/existing_history"
    MERGED_FILE="$TEMP_DIR/merged_history"

    cp "$FULL_PATH" "$INCOMING_FILE"

    LOCAL_BACKUP="$HOME/.cache/zsh_history_local_backup"
    if [[ -f "$LOCAL_BACKUP" ]]; then
      cp "$LOCAL_BACKUP" "$EXISTING_FILE"
    else
      if [[ -f "$FULL_PATH" ]]; then
        cp "$FULL_PATH" "$LOCAL_BACKUP"
        cp "$FULL_PATH" "$EXISTING_FILE"
      else
        cp "$INCOMING_FILE" "$MERGED_FILE"
        cp "$INCOMING_FILE" "$LOCAL_BACKUP"
        mv "$INCOMING_FILE" "$FULL_PATH"
        rm -rf "$TEMP_DIR"
        exit 0
      fi
    fi

    INCOMING_SIZE=$(wc -l < "$INCOMING_FILE")
    EXISTING_SIZE=$(wc -l < "$EXISTING_FILE")

    if [[ "$EXISTING_SIZE" -gt "$INCOMING_SIZE" ]]; then
      cp "$EXISTING_FILE" "$MERGED_FILE"
      echo "Keeping local history ($EXISTING_SIZE lines) instead of incoming ($INCOMING_SIZE lines)"
    else
      cp "$INCOMING_FILE" "$MERGED_FILE"
      echo "Using incoming history ($INCOMING_SIZE lines) instead of local ($EXISTING_SIZE lines)"
    fi

    cp "$MERGED_FILE" "$LOCAL_BACKUP"
    rm -f "$FULL_PATH"
    cp "$MERGED_FILE" "$FULL_PATH"
    rm -rf "$TEMP_DIR"
  '';
}
