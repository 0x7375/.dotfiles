# restore btrfs snapshot

```
~/documents $ lsblk
NAME        FSTYPE        SIZE MOUNTPOINTS
sda         iso9660      28.7G
├─sda1      iso9660         2G /run/media/ayko/nixos-minimal-25.05-x86_64
└─sda2      vfat            3M
nvme1n1                 232.9G
├─nvme1n1p1 vfat          512M /boot
└─nvme1n1p2 crypto_LUKS 232.4G
  └─crypted btrfs       232.4G /swap
                               /nix/store
                               /nix
                               /home
                               /
nvme0n1                 931.5G
├─nvme0n1p1                16M
├─nvme0n1p2 ntfs        930.9G
└─nvme0n1p3 ntfs          642M
```

## open and mount btrfs root

```
cryptsetup open /dev/nvme1n1p2 crypted

# mkdir -p /mnt/btrfs-root
# mount -o subvol=/ /dev/mapper/crypted /mnt/btrfs-root
```

## list snapshots

```
# ls -la /mnt/btrfs-root/snapshots
```

## restore snapshot

```
# btrfs subvolume delete /mnt/btrfs-root/home
# btrfs subvolume snapshot /mnt/btrfs-root/snapshots/snapshot_to_restore /mnt/btrfs-root/home
```

## cleanup

```
# umount /mnt/btrfs-root
# cryptsetup close crypted
```

# send snapshot to another machine

```
# btrfs subvolume snapshot -r /home /snapshots/home-ssh
# btrfs send /snapshots/home-ssh | ssh user@remote-server "btrfs receive /snapshots/home-received-ssh"
# btrfs subvolume delete /snapshots/home-ssh
```
