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
        rpi5 = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ({...}: {
              imports = with nixos-raspberrypi.nixosModules; [
                ./hardware-configuration.nix
                raspberry-pi-5.base
                raspberry-pi-5.bluetooth
              ];
            })
            ./modules
            ({ ... }: {
              networking.hostName = "rpi5";
              users.users.user = {
                initialPassword = "1234";
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
                  options = [
                    "noatime"
                    "noauto"
                    "x-systemd.automount"
                    "x-systemd.idle-timeout=1min"
                  ];
                };
                "/" = {
                  options = [ "noatime" ];
                };
              };
            })
          ];
        };
      };
    };
}
