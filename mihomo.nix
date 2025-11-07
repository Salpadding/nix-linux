{ config, lib, pkgs, ... }:

let
  constants = import ./constants.nix;
  mihomoUid = builtins.toString constants.mihomoUid;
  tproxyRouteTable = builtins.toString constants.tproxyRouteTable;
in
{
  systemd.services.mihomo = {
    enable = true;
    after = ["network-online.target"];
    description = "Mihomo daemon, A rule-based proxy in Go."; 
    documentation = ["https://wiki.metacubex.one/"];
    requires = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = lib.mkForce "${pkgs.mihomo}/bin/mihomo -d /opt/lib/mihomo -f /opt/conf/mihomo/router.yaml";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN CAP_NET_RAW";
      NoNewPrivileges = false;
      User = "mihomo";
      Group = "mihomo";
    };
  };

  #ip rule list
  #ip route show table 100
  systemd.services."iprule-table-100" = {
    description = "Policy routing: fwmark ${mihomoUid} -> table ${tproxyRouteTable}, and local route via lo";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ''
          ${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip rule list | \
            grep -q "from all fwmark ${mihomoUid} lookup ${tproxyRouteTable}" \
           || ${pkgs.iproute2}/bin/ip rule add fwmark ${mihomoUid} lookup ${tproxyRouteTable} || true'
        ''
        ''
        ${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip route add \
          local 0.0.0.0/0 dev lo table ${tproxyRouteTable} || true'
        ''
      ];
      ExecStop = [
        # remove the rules on stop
        ''
        ${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip rule del \
          fwmark ${mihomoUid} lookup ${tproxyRouteTable} || true'
        ''
        ''
        ${pkgs.bash}/bin/bash -c '${pkgs.iproute2}/bin/ip route del table \
        ${tproxyRouteTable} local 0.0.0.0/0 dev lo || true'
        ''
      ];
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}