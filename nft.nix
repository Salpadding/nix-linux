{ config, lib, pkgs, ... }:

{
  networking.nftables.enable = true;
  networking.nftables.ruleset = builtins.readFile ./dist/nftables.nft;
}
