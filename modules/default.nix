{ ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  imports = [
    ./networking.nix
    ./pkgs.nix
    ./users.nix
  ];
}
