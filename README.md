# NixOS on Raspberry Pi 5

## Installation

### 1. Build the Installer Image

Build the installer image for Raspberry Pi 5 using the following command:

```bash
nix build github:nvmd/nixos-raspberrypi#installerImages.rpi5 --system aarch64-linux
```

**Note**: You must run this command as a trusted user.

### 2. Flash the Image

Write the built image to a USB drive (not the SD card).

**Important**: The installer will format the SD card, so do not use the SD card for this step.

### 3. Run the Installer

1. Remove the SD card from the Raspberry Pi 5.
2. Insert the USB drive with the installer image.
3. Boot the Raspberry Pi.
4. Once the installer is running, insert the SD card for installation.

### 4. Configure a Remote Builder

To speed up compilation, especially on a Raspberry Pi, configure a remote builder by following these steps:

1. Make sure you can SSH into the remote machine without needing a password:

```bash
ssh-keygen -t ed25519 -C <comment>
ssh-copy-id user@remote-host
ssh user@remote-host
```

2. Edit `~/.config/nix/nix.conf` to include the builders configuration:

```bash
mkdir -p ~/.config/nix
echo "builders = ssh://<user>@<ip/host> aarch64-linux" >> ~/.config/nix/nix.conf
```

**Note**: Remote builds can significantly improve compilation performance.

### 5. Prepare the SD Card

1. Partition the SD card:

```bash
parted /dev/mmcblk0 -- mklabel gpt
parted /dev/mmcblk0 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/mmcblk0 -- mkpart primary ext4 512MiB 100%
mkfs.vfat -F 32 /dev/mmcblk0p1
mkfs.ext4 /dev/mmcblk0p2
```

2. Mount to `/mnt`:

```bash
mount /dev/mmcblk0p2 /mnt
mkdir -p /mnt/boot/firmware
mount /dev/mmcblk0p1 /mnt/boot/firmware
```

3. Generate hardware config for correct UUIDs:

```bash
nixos-generate-config --root /mnt
```

4. Copy it into this repo:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix .
git add .
```

### 6. Install NixOS

1. Run the following command to build NixOS:

```bash
nix build .#nixosConfigurations.rpi5.config.system.build.toplevel
```

2. After that, install it onto the board:

```bash
nixos-install --flake .#rpi5
```

## Customization

You can use this repository as a template and edit the `modules` directory.

After you made your changes, use the following to update:

```bash
nixos-rebuild switch --flake .#rpi5
```

**Note**: You need to reconfigure remote builders.

## Troubleshooting

### WiFi Issues while Installing

The file `/etc/resolv.conf` defines your DNS servers. If it’s empty or incorrect, you can manually add DNS servers:

```bash
sudo nano /etc/resolv.conf
```

Add the following:

```txt
nameserver 8.8.8.8
nameserver 1.1.1.1
```

Then, add a link and restart systemd-resolved:

```bash
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```
