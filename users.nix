
{ config, lib, pkgs, ... }:

let 
  constants = builtins.fromJSON (builtins.readFile ./constants.json);
in
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
    uid = constants.mihomoUid;
  };

  users.groups.mihomo = {
    gid = constants.mihomoUid;
  };
}
