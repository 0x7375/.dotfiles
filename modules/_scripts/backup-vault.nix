{
  pkgs,
  server ? "pearlman",
  ...
}:

pkgs.writeShellApplication {
  name = "backup-vault";
  runtimeInputs = [ pkgs.rsync ];
  text =
    # bash
    ''
      REMOTE_PATH=/data/backups/vault-export
      REMOTE="root@${server}"

      USAGE="Usage: backup-vault <export.json> <usb-mount-path>"
      EXPORT_FILE="''${1:?$USAGE}"
      USB_PATH="''${2:?$USAGE}"

      [[ -f "$EXPORT_FILE" ]] || { echo "File not found: $EXPORT_FILE"; exit 1; }
      [[ -d "$USB_PATH" ]]    || { echo "USB path not found: $USB_PATH"; exit 1; }

      FILENAME="bitwarden_$(date +%Y%m%d_%H%M%S).json"

      confirm() {
          read -rn1 -p "$1 [Y/n] " REPLY
          echo
          [[ "''${REPLY:-Y}" =~ ^[Yy]$ ]]
      }

      if confirm "Copy to server?"; then
          ssh "$REMOTE" -- mkdir -p "$REMOTE_PATH"
          scp "$EXPORT_FILE" "$REMOTE:$REMOTE_PATH/$FILENAME" && \
          echo "* Copied to $REMOTE -> $REMOTE_PATH/$FILENAME"
      fi

      if confirm "Copy to USB?"; then
          cp "$EXPORT_FILE" "$USB_PATH/$FILENAME" && \
          echo "* Copied to USB -> $USB_PATH/$FILENAME"
      fi

      if confirm "Delete original?"; then
          shred -u "$EXPORT_FILE" && \
          echo "* Deleted $EXPORT_FILE"
      fi
    '';
}
