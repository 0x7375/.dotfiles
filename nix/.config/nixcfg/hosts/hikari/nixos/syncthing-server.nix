{
  pkgs,
  lib,
  config,
  myLib,
  ...
}:

lib.mkIf config.me.secrets.enable {
  networking.firewall.allowedTCPPorts = [ 8384 ];

  sops.secrets."hikari/syncthing/cert" = {
    owner = config.me.user;
  };

  sops.secrets."hikari/syncthing/key" = {
    owner = config.me.user;
  };

  services.syncthing = {
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    key = "${config.sops.secrets."hikari/syncthing/key".path}";
    cert = "${config.sops.secrets."hikari/syncthing/cert".path}";
    settings = {
      devices = {
        "neiro" = {
          id = "JJ62FKA-U5HTR5S-NJ7A4EJ-TMO66SZ-QNUOYUA-CCQMUIB-STDX4RE-VCGEKAB";
        };
        "yugen" = {
          id = "E5O7YJW-QG5GRP2-GTOIL44-GARB6IA-KVLTV4L-PNELNSW-U54NY7P-N3R5NQW";
        };
        "ryusei" = {
          id = "VQTBWUL-XN5DIYJ-2FVH2L5-METP43G-QGVR6HG-4E5TGBC-3G6MUN4-EEUHGQB";
        };
        "tsuno" = {
          id = "XAFE3W3-FG4XVNB-GCPR4CU-XAYED7H-AISJHBI-JREWBFT-CLUTRPZ-EVYV5AH";
        };
      };
      folders = with myLib; {
        documents = syncthingDirConfig {
          path = "documents";
          devices = [
            "yugen"
            "ryusei"
          ];
        };
        uni = syncthingDirConfig {
          path = "uni";
          devices = [
            "yugen"
            "ryusei"
          ];
        };
        pictures = syncthingDirConfig {
          path = "pictures";
          devices = [
            "yugen"
            "ryusei"
          ];
        };
        ds = syncthingDirConfig {
          path = "games/ds";
          devices = [
            "yugen"
            "ryusei"
          ];
        };
        notes = syncthingDirConfig {
          path = "notes";
          devices = [
            "yugen"
            "ryusei"
            "neiro"
          ];
        };
        perso = syncthingDirConfig {
          path = "perso";
          devices = [
            "yugen"
            "ryusei"
          ];
        };
        photos = syncthingDirConfig {
          path = "photos";
          devices = [
            "yugen"
            "ryusei"
            "neiro"
          ];
        };
        zsh_history = syncthingDirConfig {
          path = ".local/state/zsh";
          devices = [
            "yugen"
            "ryusei"
          ];
          extraConfig = {
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
        universite = syncthingDirConfig {
          path = "documents/pdf/universite";
          devices = [
            "neiro"
          ];
        };
        windows = syncthingDirConfig {
          path = "windows";
          devices = [
            "tsuno"
            "ryusei"
            "yugen"
          ];
        };
      };
    };
  };
}
