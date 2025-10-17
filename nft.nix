{ config, lib, pkgs, ... }:

{
  networking.nftables.enable = true;
  networking.nftables.ruleset = builtins.readFile ./nftables.nft;
}
