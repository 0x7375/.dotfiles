# Restic maintenance commands

## List snapshots

List all snapshots in the repository

```bash
restic -r /srv/backups/syncthing --password-file /run/secrets/password_file snapshots
restic -r rclone:google:media --password-file /run/secrets/password_file snapshots
```

## List Files or Directories in Backups

List all files in the latest snapshot, specific snapshot, or a specific path in
a snapshot

```bash
restic -r /srv/backups/syncthing --password-file /run/secrets/password_file ls latest
restic -r /srv/backups/syncthing --password-file /run/secrets/password_file ls snapshot-id
restic -r /srv/backups/syncthing --password-file /run/secrets/password_file ls latest:/home/youruser/documents
```
