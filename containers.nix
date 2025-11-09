{ config, lib, pkgs, ... }:

let
  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      debug
    }
    http://nexus.router.i.home {
      reverse_proxy http://nexus:8081
    }
    http://athens.router.i.home {
      reverse_proxy http://athens:3000
    }
    http://verdaccio.router.i.home {
      reverse_proxy http://verdaccio:4873
    }
    http://kellnr.router.i.home {
      reverse_proxy http://kellnr:8000
    }
  '';
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
  constants = builtins.fromJSON (builtins.readFile ./constants.json);
  caddyUid = builtins.toString constants.caddyUid;
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/caddy 0755 ${caddyUid} ${caddyUid} -"
    "d /var/lib/athens 0755 1000 1000 -"
    "d /var/lib/nexus 0770 200 200 -"
    "d /var/lib/verdaccio 0750 10001 10001 -"
    "d /var/lib/verdaccio/storage 0770 10001 10001 -"
    "d /var/lib/verdaccio/plugins 0770 10001 10001 -"
    "d /var/lib/kellnr 0770 root root -"
  ];
  virtualisation.oci-containers = {
    backend = "docker"; # 或 "podman"
    containers.nexus = {
      image = "sonatype/nexus3:latest";
      volumes = [
        "/var/lib/nexus:/nexus-data"
      ];
      networks = [ "homelab" ];
      log-driver = "local";
    };
    # containers.caddy = {
    #     image = "caddy:2-alpine";
    #     ports = [
    #       "80:80"
    #     ];
    #     volumes = [
    #       # 只读挂载 Caddyfile
    #       "${caddyfile}:/etc/caddy/Caddyfile:ro"
    #       "/var/lib/caddy/data:/data"
    #       "/var/lib/caddy/config:/config"
    #     ];
    #     networks = [ "homelab" ];
    #     log-driver = "local";
    # };
    containers.athens = {
      image = "gomods/athens";
      volumes = [
        "/var/lib/athens:/var/lib/athens"
      ];
      environment = {
        ATHENS_STORAGE_TYPE = "disk";
        ATHENS_DISK_STORAGE_ROOT = "/var/lib/athens";
        ATHENS_LOG_LEVEL = "info";
        ATHENS_GITHUB_TOKEN = secrets.githubToken;
        ATHENS_GLOBAL_ENDPOINT = "https://goproxy.cn/";
      };
      networks = [ "homelab" ];
      log-driver = "local";
    };
    containers.verdaccio = {
      image = "verdaccio/verdaccio:latest";
      volumes = [
        "/var/lib/verdaccio/storage:/verdaccio/storage"
        "/var/lib/verdaccio/plugins:/verdaccio/plugins"
      ];
      networks = [ "homelab" ];
      log-driver = "local";
    };
    containers.kellnr = {
      image = "ghcr.io/kellnr/kellnr:5";
      environment = {
        "KELLNR_ORIGIN__HOSTNAME" = "kellnr.router.i.home";
      };
      volumes = [
        "/var/lib/kellnr:/opt/kdata"
      ];
      networks = [ "homelab" ];
      log-driver = "local";
    };
  };
}