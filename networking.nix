{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };
  networking = {
    hostName = "nixos";
    interfaces = {
      br0.ipv4.addresses = [
        { address = "192.168.2.216"; prefixLength = 24; }
      ];
      br0.useDHCP = false;
    };
    defaultGateway = "192.168.2.1";
    nameservers = [ "192.168.2.1" ];
    bridges = {
      br0 = {
        interfaces = [ "enp2s0" ];
      };
    };
    firewall.enable = false;
  };
}

