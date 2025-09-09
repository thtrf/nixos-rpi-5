{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hello
    git
    curl
  ];
}
