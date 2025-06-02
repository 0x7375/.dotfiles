# Dotfiles

NixOS configuration for an nvidia desktop, thinkpad laptop, a raspberry pi and
wsl. Flake uses [home-manager](https://github.com/nix-community/home-manager) as a nixos module,
and [sops-nix](https://github.com/Mic92/sops-nix) for secrets.

## Nixos-anywhere installation

### Pre-requisites

Store password for disk encryption in a file, and create the structure for the
ssh key to be passed to nixos-anywhere

```bash
host=ryusei
user=ayko

 echo -n "luksPassword" > /tmp/secret.key
root=$(mktemp -d)
install -Dm 600 ~/$host $root/home/$user/.ssh/id_ed25519
```

Secure boot keys can optionally be generated with sbctl to be passed to
nixos-anywhere

```bash
sbctl create-keys
mkdir -p $root/var/lib
sudo cp -r /var/lib/sbctl $root/var/lib
sudo chown -R ${user}:users $root/var/lib/sbctl
```

### Install

Note: SSHPASS and --env-password are only needed if public key auth is not set up

```bash
SSHPASS=remote-pw nix run nixpkgs#nixos-anywhere -- --env-password \
--disk-encryption-keys /tmp/secret.key /tmp/secret.key \
--extra-files "$root" --chown /home/$user 1000:100 \
--flake path:.#$host root@$host
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

Connect to wifi if needed, `nmtui`, and clone the repo

```bash
git clone https://codeberg.org/0x7E/.dotfiles ~/.config/nixcfg
```

Copy ssh key over from another machine (or just disable secrets in options
temporarily)

```bash
scp /path/to/ssh-key remote:~/.ssh/id_ed25519
```

Put ssh key in the right place and install nixos

```bash
chmod 600 ~/.ssh/id_ed25519
install -Dm 600 -o $host -g users ~/.ssh/id_ed25519 /mnt/home/$user/.ssh/
nixos-install --root /mnt --flake ~/.config/nixcfg#hostname
```
