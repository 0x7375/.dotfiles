# Dotfiles

Dotfiles managed with gnu stow

NixOS configuration for an nvidia desktop, thinkpad laptop, a raspberry pi and wsl.
Flake uses [home-manager](https://github.com/nix-community/home-manager), and [agenix](https://github.com/ryantm/agenix) for secrets.

`nd` script to show changes and commit after every successfull rebuild to a local git repo inside nixcfg

```
$ cd nix/.config/nixcfg; git init; mv .git .nix-git
$ export GIT_DIR=.nix-git; git add .; git commit -m "initial commit"
```

## Using nixos-anywhere
add luks password to a file on the target
```
$ ssh root@target
#  echo -n "luksPassword" > /tmp/secret.key
```
install
```
$ nix run nixpkgs#nixos-anywhere -- --flake .#target root@target
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
# mkswap /dev/disk -L NIXLABEL
# mkfs.fat -F 32 /dev/disk -n NIXLABEL
# mkfs.ext4 /dev/disk -L NIXLABEL
```

### mount
```
# mount /dev/disk /mnt
# mount --mkdir /dev/disk /mnt/root
# swapon /dev/disk/by-label/NIXSWAP
```

### install
```
$ git clone https://git.sr.ht/~ayko/.dotfiles ~/.dotfiles
$ cd ~/.dotfiles; stow nix
$ sed -i 's/\(secrets.enable = \)true/\1false/' ~/.config/nixcfg/hosts/hostname/options.nix # temporarily disable secrets
# nixos-install --root /mnt --flake ~/.config/nixcfg#hostname
```
