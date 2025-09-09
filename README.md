# NixOS on Raspberry Pi 5

## 1. Build the Installer Image

Build the installer image for Raspberry Pi 5 using the following command:

```bash
nix build github:nvmd/nixos-raspberrypi#installerImages.rpi5 --system aarch64-linux
```

**Note**: You must run this command as a trusted user.

## 2. Flash the Image

Write the built image to a USB drive (not the SD card).

**Important**: The installer will format the SD card, so do not use the SD card for this step.

## 3. Run the Installer

1. Remove the SD card from the Raspberry Pi 5.
2. Insert the USB drive with the installer image.
3. Boot the Raspberry Pi.
4. Once the installer is running, insert the SD card for installation.

## 4. Configure a Remote Builder

To speed up compilation, especially on a Raspberry Pi, configure a remote builder by following these steps:

1. Make sure you can SSH into the remote machine without needing a password:

```bash
ssh-copy-id user@remote-host
ssh user@remote-host
```

2. Edit `/etc/nix/nix.conf` to include the builders configuration:

```bash
echo "builders = @/etc/nix/machines" | sudo tee -a /etc/nix/nix.conf
```

3. Define your remote machines in `/etc/nix/machines` with the format:

```
<ssh-remote> <system> <ssh-opts> <max-jobs> <speed-factor> [features...]
```

**Note**: Remote builds can significantly improve compilation performance.

## 5. Install NixOS

Run the following command to install NixOS:

```bash
nixos-rebuild switch --flake github:thtrf/nixos-rpi-5 --builders ''
```

## LOL

nix = {
  extraOptions = ''
    builders = ssh://user@remote-host x86_64-linux
  '';
};
