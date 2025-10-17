{ config, lib, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = true;
    PermitRootLogin = "yes";
  };

  users.users.alice = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqWGcDJIN/HoT8pa3KeqSJ4gN88MulphjOi68ZTXCFh C5390852@H7DWCK9Y5C"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqWGcDJIN/HoT8pa3KeqSJ4gN88MulphjOi68ZTXCFh C5390852@H7DWCK9Y5C"
    ];
  };
}
