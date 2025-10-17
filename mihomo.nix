
{ config, lib, pkgs, ... }:

{
  systemd.services.mihomo = {
    enable = true;
    after = ["network-online.target"];
    description = "Mihomo daemon, A rule-based proxy in Go."; 
    documentation = ["https://wiki.metacubex.one/"];
    requires = ["network-online.target"];
    serviceConfig = {
      ExecStart = lib.mkForce "${pkgs.mihomo}/bin/mihomo -d /opt/lib/mihomo -f /opt/conf/mihomo/hybrid.yaml";
      User = "root";
      Group = "root";
    };
  };
}