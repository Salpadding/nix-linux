{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [
    "nft_tproxy"      
    "nf_tproxy_ipv4"
    "xt_TPROXY"
    "8021q"
  ];
}
