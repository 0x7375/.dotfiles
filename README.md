# Dotfiles

Dotfiles managed with gnu stow

NixOS configuration for an nvidia desktop, thinkpad laptop, a raspberry pi and wsl.
Flake uses [home-manager](https://github.com/nix-community/home-manager), and [agenix](https://github.com/ryantm/agenix) for secrets.

`nd` script to show changes and commit after every successfull rebuild to a local git repo inside nixcfg

## Using nixos-anywhere
connect to wifi if needed (nmtui)
add luks password to a file on the target
```
$  echo -n "luksPassword" > /tmp/secret.key
```
install
```
$ root=$(mktemp -d)
$ install -Dm 600 ~/remote_pkey $root/home/ayko/.ssh/id_ed25519
$ SSHPASS=remote-pw nix run nixpkgs#nixos-anywhere -- --disk-encryption-keys /tmp/secret.key /tmp/secret.key --env-password --extra-files "$root" --chown /home/ayko 1000:100 --flake path:.#remote root@remote
```

## Making a bootable USB drive
building the iso
```
$ nix build .\#nixosConfigurations.isoImg.config.system.build.isoImage 
```
flashing the iso
```
$ sudo dd if=result/iso/nixos.iso of=/dev/disk bs=4M status=progress conv=sync
```

## Manual installation
### partitioning
```
# cfdisk /dev/disk
# cryptsetup luksFormat /dev/disk --label NIXLUKS
# cryptsetup open /dev/disk cryptlvm
# pvcreate /dev/mapper/cryptlvm
# vgcreate vg /dev/mapper/cryptlvm
# lvcreate -L 16G vg -n swap
# lvcreate -l 100%FREE vg -n root
```

### formatting
```
# mkswap /dev/disk -L NIXSWAP
# mkfs.fat -F 32 /dev/disk -n NIXBOOT
# mkfs.ext4 /dev/disk -L NIXROOT
```

### mount
```
# mount /dev/disk /mnt
# mount --mkdir /dev/disk /mnt/root
# swapon /dev/disk/by-label/NIXSWAP
```

### install
```
$ git clone https://codeberg.org/0xB0F/.dotfiles ~/.dotfiles
$ cd ~/.dotfiles; stow nix
```
from another machine
```
$ scp /path/to/ssh-key remote:~/.ssh/id_ed25519
```
back to the target machine
```
$ chmod 600 ~/.ssh/id_ed25519
# install -Dm 600 -o ayko -g users ~/.ssh/id_ed25519 /mnt/home/ayko/.ssh/
# nixos-install --root /mnt --flake ~/.dotfiles/nix/.config/nixcfg#hostname
```

## Local rebuild repo setup
```
$ cd nix/.config/nixcfg; git init; mv .git .nix-git
$ export GIT_DIR=.nix-git
$ git config user.name name; git config user.email email
$ git add .; git commit -m "initial commit"
```

