{
  pkgs,
  myLib,
  config,
  lib,
  ...
}:

lib.mkIf (config.me.syncthing-client.enable && config.me.secrets.enable) {
  programs.fuse.userAllowOther = true;

  services.syncthing = {
    settings = {
      devices = {
        "server" = {
          id = "A4SN3P4-3UDLBHB-X3IG2A3-AZCXD5S-SQ6CTOY-SN3STI2-LVUGEP7-VT4X7A4";
        };
      };
      folders = with myLib; {
        documents = syncthingDirConfig {
          path = "documents";
          devices = [
            "server"
          ];
        };
        uni = syncthingDirConfig {
          path = "uni";
          devices = [
            "server"
          ];
        };
        pictures = syncthingDirConfig {
          path = "pictures";
          devices = [
            "server"
          ];
        };
        ds = syncthingDirConfig {
          path = "games/ds";
          devices = [
            "server"
          ];
        };
        notes = syncthingDirConfig {
          path = "notes";
          devices = [
            "server"
          ];
        };
        perso = syncthingDirConfig {
          path = "perso";
          devices = [
            "server"
          ];
        };
        photos = syncthingDirConfig {
          path = "photos";
          devices = [
            "server"
          ];
        };
        zsh_history = syncthingDirConfig {
          path = ".local/state/zsh";
          devices = [
            "server"
          ];
          extraConfig = {
            maxConflicts = 3;
            ignoreDelete = true;
            ignore = [
              "*"
              "!history"
            ];
            versioning = {
              type = "external";
              params = {
                command = "${pkgs.writeShellScript "syncthing-zsh-history-handler" ''
                  FOLDER_PATH="$1"
                  FILE_PATH="$2"

                  if [[ "$FILE_PATH" != *"history"* ]]; then
                    rm -f "$FOLDER_PATH/$FILE_PATH"
                    exit 0
                  fi

                  BACKUP_DIR="$HOME/.cache/zsh_history_backups"
                  mkdir -p "$BACKUP_DIR"

                  TIMESTAMP=$(date +%Y%m%d%H%M%S)
                  cp "$FOLDER_PATH/$FILE_PATH" "$BACKUP_DIR/history.$TIMESTAMP"

                  rm -f "$FOLDER_PATH/$FILE_PATH"

                  (
                    sleep 5
                    HISTORY_FILE="$FOLDER_PATH/$FILE_PATH"
                    if [[ ! -f "$HISTORY_FILE" ]]; then
                      exit 0
                    fi
                    
                    BEST_BACKUP=""
                    BEST_LINES=0
                    
                    for backup in "$BACKUP_DIR"/history.*; do
                      if [[ -f "$backup" ]]; then
                        LINES=$(wc -l < "$backup")
                        if (( LINES > BEST_LINES )); then
                          BEST_BACKUP="$backup"
                          BEST_LINES=$LINES
                        fi
                      fi
                    done
                    
                    CURRENT_LINES=$(wc -l < "$HISTORY_FILE")
                    if [[ -n "$BEST_BACKUP" && $BEST_LINES -gt $CURRENT_LINES ]]; then
                      echo "Restoring backup with $BEST_LINES lines instead of current with $CURRENT_LINES lines" > /tmp/saluuiuu
                      cp "$BEST_BACKUP" "$HISTORY_FILE"
                    fi
                    
                    ls -t "$BACKUP_DIR"/history.* | tail -n +3 | xargs -r rm
                  ) &
                ''} %FOLDER_PATH% %FILE_PATH%";
              };
            };
          };
        };
        windows = syncthingDirConfig {
          path = "windows";
          devices = [
            "server"
          ];
        };
      };
    };
  };
}
