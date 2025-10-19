{ config, lib, pkgs, ... }:

{
    systemd.services.nix-daemon.environment = {
    http_proxy  = "http://192.168.2.211:7893";
    https_proxy = "http://192.168.2.211:7893";
    no_proxy    = "localhost,127.0.0.1,::1";
  };
}
