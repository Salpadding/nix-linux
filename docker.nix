{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "log-driver" = "local";
      "log-opts" = {
        "max-size" = "32m";
        "max-file" = "3";
      };
    };
  };

  systemd.services.docker-network-homelab = {
    description = "Create docker network 'homelab' if missing";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect homelab >/dev/null 2>&1 \
        || ${pkgs.docker}/bin/docker network create --driver=bridge \
        --opt com.docker.network.bridge.name=br-homelab homelab'
      '';
    };
  };
}