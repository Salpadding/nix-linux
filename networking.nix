{ config, lib, pkgs, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
in
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.br-homelab.rp_filter" = 0;
    "net.ipv4.conf.all.route_localnet" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };
  networking = {
    wireless.enable = true;
    wireless.networks = {
      "306-mgmt" = {
        psk = secrets.mgmtWifiPsk;
      };
    };
    hostName = "nixos";
    vlans = {
      wan = {
        id = 2;
        interface = "enp2s0";
      };
      lan = {
        id = 3;
        interface = "enp2s0";
      };
    };
    interfaces = {
      wan = {
        useDHCP = false;
        ipv4.addresses = [
        { address = "192.168.1.254"; prefixLength = 24; }
        ];
      };
      lan = {
        useDHCP = false;
        ipv4.addresses = [
        { address = "192.168.16.1"; prefixLength = 24; }
        ];
      };
      dummy0 = {
        useDHCP = false;
        virtual = true;
        ipv4.addresses = [ { address = "192.168.254.1"; prefixLength = 24; } ];
      };
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "127.0.0.1" ];
    firewall.enable = false;
  };
}

