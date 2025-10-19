
{ config, lib, pkgs, ... }:

{
  users.users.alice = {
    isNormalUser = true;
    description = "Alice";
    extraGroups = [ "wheel" ]; # Sudo access
    shell = pkgs.bash;
    home = "/home/alice";
  };

  users.users.mihomo = {
    isSystemUser = true;

    description = "mihomo";
    group = "mihomo";
    uid = 2000;
  };

  users.groups.mihomo = {
    gid = 2000;
  };
}
