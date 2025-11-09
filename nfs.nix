{ config, lib, pkgs, ... }:

{
  boot.supportedFilesystems = [ "nfs" "nfs4" ];
  services.rpcbind.enable = true;
}