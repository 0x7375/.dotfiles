# NixOS configuration

NixOS configuration for various machines that follows the dendritic pattern,
uses [flake-parts](https://github.com/hercules-ci/flake-parts) for structuring
the flake itself,
[nix-wrappers-modules](https://github.com/BirdeeHub/nix-wrapper-modules) for
wrapping packages, [hjem](https://github.com/feel-co/hjem) for user file
management, [sops-nix](https://github.com/Mic92/sops-nix) for secrets and
[disko](https://github.com/nix-community/disko) for disk partitioning.

| Name       | Role    | Description                                                             |
| :--------- | :------ | :---------------------------------------------------------------------- |
| `pearlman` | Server  | Unowhy Y13 2020 laptop (N3450). Runs syncthing, media stack and others. |
| `wilson`   | Server  | Raspberry pi 4 2GB, previously used as a home server.                   |
| `cray`     | Desktop | Main workstation, uses an Nvidia gpu.                                   |
| `naitoh`   | Laptop  | Main laptop, thinkpad e14 gen4 AMD.                                     |
| `mach`     | Laptop  | M1 Macbook, uses nix-darwin.                                            |
| `julliard` | WSL     | Windows WSL config.                                                     |
| `isoImg`   | ISO     | Custom NixOS iso.                                                       |

## Nixos-anywhere installation

### Pre-requisites

Store password for disk encryption in a file, and create the structure for
necessary files to be passed to nixos-anywhere (note: created files will be
owned by root)

```bash
host=naitoh
user=ayko

 echo -n "luksPassword" > /tmp/secret.key
root=$(mktemp -d)
install -Dm 600 ~/tpm_key $root/etc/tpm_key
```

Secure boot keys can optionally be generated with sbctl to be passed to
nixos-anywhere

```bash
mkdir -p $root/var/lib/sbctl/keys
sbctl create-keys --directory $root/var/lib/sbctl/keys --disable-sandbox
```

### Install

Note: SSHPASS and --env-password are only needed if public key auth is not set
up

```bash
SSHPASS=remote-pw nix run nixpkgs#nixos-anywhere -- --env-password \
--disk-encryption-keys /tmp/secret.key /tmp/secret.key \
--extra-files "$root" --flake path:.#$host root@$host
```

### Optional: enable secure boot

Verify entries are signed

```bash
sbctl verify
```

Warning: On Thinkpad devices, do not select "Clear All Secure Boot Keys" as it
will drop the Forbidden Signature Database (dbx). Make sure to only select
"Reset to Setup Mode".

Inside the bios: security -> secure boot -> enable secure boot and select reset
to setup mode
([guide](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot))

Enroll keys

```bash
sbctl enroll-keys --microsoft
bootctl status
```

Secure boot should now work and we can reboot

### Optional: require fido2 key to boot

Enroll the keys, one at a time with:

```
sudo systemd-cryptenroll --fido2-device=auto /dev/crypted-device
```

Find regular password keyslot and wipe it

```
sudo cryptsetup luksDump /dev/nvme0n1p2

sudo systemd-cryptenroll --wipe-slot=password /dev/crypted-device
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

Connect to wifi if needed, `nmtui`, and clone the repo

```bash
git clone https://codeberg.org/0x7E/nixcfg ~/.config/nixcfg
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

## Darwin

- Install lix: `curl -sSf -L https://install.lix.systems/lix | sh -s -- install`
- Install secretive and generate new key, create the suggested .ssh/config file
- `sudo age-plugin-se keygen --access-control=none -o /var/lib/sops-nix/se-identity.txt"
- Pull nix-secrets and updatekeys inside a shell with all the plugins and stuff
- `mkdir .config && cd .config && git clone git@codeberg.org:0x7E/nixcfg`
- `nix flake update secrets`
- Give full disk access to terminal
- `sudo nix run github:LnL7/nix-darwin -- build --flake .#mach`
- `sudo ./result/activate`
- `sudo darwin-rebuild switch`
- Privacy & Security -> Allow applications from `Anywhere`
