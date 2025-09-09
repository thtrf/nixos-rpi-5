{ ... }:

{
  users.users = {
    user = {
      initialPassword = "1234";
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
}
