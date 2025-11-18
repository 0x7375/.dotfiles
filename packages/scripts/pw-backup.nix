{
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "pw-backup";
  runtimeInputs = with pkgs; [
    openssl
    gnutar
    coreutils
  ];
  text = ''
    BACKUP_FILE="/srv/pw-backup.tar.gz.enc"
    TEMP_DIR=$(mktemp -d)
    TEMP_ARCHIVE="$TEMP_DIR/archive.tar.gz"
    TEMP_DECRYPTED="$TEMP_DIR/decrypted.tar.gz"

    cleanup() {
        rm -rf "$TEMP_DIR"
    }
    trap cleanup EXIT

    if [ $# -eq 0 ]; then
        echo "Usage: $0 <file1> [file2] [file3] ..."
        exit 1
    fi

    read -rs -p "Enter password: " PASSWORD
    echo

    if [ -f "$BACKUP_FILE" ]; then
        echo "Decrypting existing backup..."
        echo -n "$PASSWORD" | openssl enc -d -aes-256-cbc -pbkdf2 -in "$BACKUP_FILE" -out "$TEMP_DECRYPTED" -pass stdin
        
        echo "Extracting archive..."
        tar -xzf "$TEMP_DECRYPTED" -C "$TEMP_DIR"
        rm "$TEMP_DECRYPTED"
    else
        read -rs -p "Confirm password: " PASSWORD_CONFIRM
        echo
        if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
            echo "Passwords do not match"
            exit 1
        fi
    fi

    echo "Adding files to archive..."
    tar -czf "$TEMP_ARCHIVE" -C "$TEMP_DIR" . "$@" 2>/dev/null || tar -czf "$TEMP_ARCHIVE" "$@"

    echo "Encrypting backup..."
    echo -n "$PASSWORD" | openssl enc -aes-256-cbc -pbkdf2 -in "$TEMP_ARCHIVE" -out "$BACKUP_FILE" -pass stdin

    chown root:root "$BACKUP_FILE"
    chmod 600 "$BACKUP_FILE"

    echo "Backup updated successfully: $BACKUP_FILE"
  '';
}
