{
  description = "Example Raspberry Pi 5 configuration flake";
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
      nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixos-raspberrypi }@inputs:
    {
      nixosConfigurations = {
        yourHostname = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ({...}: {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.bluetooth
              ];
            })
            ({ ... }: {
              networking.hostName = "server";
              users.users.yourUserName = {
                initialPassword = "server";
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                ];
              };

              services.openssh.enable = true;
            })

            ({ ... }: {
              fileSystems = {
                "/boot/firmware" = {
                  device = "/dev/disk/by-uuid/2175-794E";
                  fsType = "vfat";
                  options = [
                    "noatime"
                    "noauto"
                    "x-systemd.automount"
                    "x-systemd.idle-timeout=1min"
                  ];
                };
                "/" = {
                  device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
                  fsType = "ext4";
                  options = [ "noatime" ];
                };
              };
            })
          ];
        };
      };
    };
}
