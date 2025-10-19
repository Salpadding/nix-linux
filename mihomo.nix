
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

  #ip rule list
  #ip route show table 100
  systemd.services."iprule-table-100" = {
    description = "Policy routing: fwmark 2000 -> table 100, and local route via lo";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        # ip rule: fwmark 1 lookup 100
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip rule list | grep -q \"from all fwmark 0x7d0 lookup 100\" || ${pkgs.iproute2}/bin/ip rule add fwmark 2000 lookup 100 || true'"
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip route add local 0.0.0.0/0 dev lo table 100 || true'"
      ];
      ExecStop = [
        # remove the rules on stop
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip rule del fwmark 2000 lookup 100 || true'"
        "${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip route del table 100 local 0.0.0.0/0 dev lo || true'"
      ];
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}