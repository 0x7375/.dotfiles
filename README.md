# Dotfiles

Dotfiles managed with gnu stow

NixOS configuration for an nvidia desktop, thinkpad laptop, a raspberry pi and
wsl. Flake uses [home-manager](https://github.com/nix-community/home-manager),
and [agenix](https://github.com/ryantm/agenix) for secrets.

`nd` script to show changes and commit after every successfull rebuild to a
local git repo inside nixcfg

## Nixos-anywhere installation

### Pre-requisites

Store password for disk encryption in a file, and create the structure for the
ssh key to be passed to nixos-anywhere

```bash
 echo -n "luksPassword" > /tmp/secret.key
root=$(mktemp -d)
install -Dm 600 ~/remote_pkey $root/home/ayko/.ssh/id_ed25519
```

Secure boot keys can optionally be generated with sbctl to be passed to
nixos-anywhere

```bash
sbctl create-keys
mkdir -p $root/var/lib
sudo cp -r /var/lib/sbctl $root/var/lib
sudo chown -R ayko:users $root/var/lib/sbctl
```

### Install

Note: SSHPASS and --env-password are only needed if public key auth is not set up

```bash
SSHPASS=remote-pw nix run nixpkgs#nixos-anywhere -- --env-password \
--disk-encryption-keys /tmp/secret.key /tmp/secret.key \
--extra-files "$root" --chown /home/ayko 1000:100 \
--flake path:.#remote root@remote
```

### Optional: enable secure boot

Verify entries are signed

```bash
sbctl verify
```

Inside the bios: security -> secure boot -> enable secure boot and select reset to setup mode
([guide](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot))

Enroll keys

```bash
sbctl enroll-keys --microsoft
bootctl status
```

Secure boot should now work and we can reboot

## Local rebuild repo setup

Commands to set up a local git repo for the nixcfg directory, this is used by
the `nd` script to have a commit per successful rebuild. `setup-dotfiles` runs
these commands.

```bash
git clone codeberg.org:0xB0F/.dotfiles ~/.dotfiles
cd ~/.dotfiles; stow nix nvim; cd ./nix/.config/nixcfg
git init; mv .git .nix-git
export GIT_DIR=.nix-git
git config user.name name; git config user.email email
git add .; git commit -m "initial commit"
```

## Making a bootable USB drive

Building the iso

```bash
nix build .#nixosConfigurations.isoImg.config.system.build.isoImage
```

Flashing the iso

```bash
sudo dd if=result/iso/nixos.iso of=/dev/disk bs=4M status=progress conv=sync
```

## Manual installation (not used, for reference)

### Partitioning

```bash
cfdisk /dev/disk
cryptsetup luksFormat /dev/disk --label NIXLUKS
cryptsetup open /dev/disk cryptlvm
pvcreate /dev/mapper/cryptlvm
vgcreate vg /dev/mapper/cryptlvm
lvcreate -L 16G vg -n swap
lvcreate -l 100%FREE vg -n root
```

### Formatting

```bash
mkswap /dev/disk -L NIXSWAP
mkfs.fat -F 32 /dev/disk -n NIXBOOT
mkfs.ext4 /dev/disk -L NIXROOT
```

### Mount

```bash
mount /dev/disk /mnt
mount --mkdir /dev/disk /mnt/root
swapon /dev/disk/by-label/NIXSWAP
```

### Install

Connect to wifi if needed, `nmtui`

```bash
git clone https://codeberg.org/0xB0F/.dotfiles ~/.dotfiles
cd ~/.dotfiles; stow nix
```

Copy ssh key over from another machine (or just disable secrets in options
temporarily)

```bash
scp /path/to/ssh-key remote:~/.ssh/id_ed25519
```

Put ssh key in the right place and install nixos

```bash
chmod 600 ~/.ssh/id_ed25519
install -Dm 600 -o ayko -g users ~/.ssh/id_ed25519 /mnt/home/ayko/.ssh/
nixos-install --root /mnt --flake ~/.dotfiles/nix/.config/nixcfg#hostname
```
