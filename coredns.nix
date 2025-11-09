{ config, pkgs, lib, ... }:

let
  coredns = pkgs.callPackage ./packages/coredns.nix {
    externalPlugins = [
      {
        name = "docker";
        repo = "github.com/kevinjqiu/coredns-dockerdiscovery";
        version = "2f65ec4";
      }
    ];
    vendorHash = "sha256-uHNFtsRdDUmYly6pKRcqgOVjabxlPnrC17hHudCycF8=";
  };
in
{
  services.coredns = {
    enable = true;
    package = coredns;
    config = ''
      .:5353 {
        docker tcp://127.0.0.1:2375 {
          domain i.docker
          hostname_domain host.i.docker
          network_aliases homelab
        }
        log
      }
    '';
  };

  environment.systemPackages = lib.mkAfter [ coredns ];
}
