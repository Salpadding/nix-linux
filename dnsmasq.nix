{ config, lib, pkgs, ... }:

{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 53; # enable dns service
      domain = "lan";
      interface-name = ["router.lan,wan" "router.lan,lan"];
      interface = [ "wan" "lan"];
      dhcp-range = [ "wan,192.168.1.2,192.168.1.249,6h" "lan,192.168.16.2,192.168.16.249,6h" ];
      local = "/lan/";
      expand-hosts = true;
      dhcp-option = [
        "wan,option:dns-server,192.168.1.1"  
        "wan,option:router,192.168.1.1" 
        "wan,option:domain-search,lan"
        "wan,option:domain-name,lan"
        "wan,tag:seal,option:dns-server,192.168.1.254"
        "wan,tag:seal,option:router,192.168.1.254"
        "lan,option:dns-server,192.168.16.1"  
        "lan,option:router,192.168.16.1" 
        "lan,option:domain-search,lan"
        "lan,option:domain-name,lan"
      ];
      conf-dir = "/opt/conf/dnsmasq/dns/,*.conf";
      server = [
        "127.0.0.1#1053"
        "/i.docker/127.0.0.1#5353"
      ];
      auth-server = ["i.home,dummy0"];
      auth-zone = ["i.home,lan/4,wan/4"];
      cname = [
        "*.mac-vm.i.home,mac-vm.i.home"
        "*.router.i.home,router.lan"
      ];
      dhcp-host = [
        "84:2f:57:1c:fa:e2,set:seal,mac-sap"
        "a4:c3:be:ec:15:1f,set:seal,mi-k80"
        "e8:4a:54:ab:83:c9,set:mi-ac,mi-ac"
        "b8:88:80:08:ea:a9,set:mi-gw,mi-gw"
        "9c:12:21:31:8c:ff,set:mi-tv,mi-tv"
        "80:3e:4f:49:b3:e4,set:dish-washer,dish-washer"
        "80:3e:4f:39:22:72,set:washing-machine,washing-machine"
        "18:41:c3:a1:b8:6a,set:fridge,fridge"
        "e4:fe:43:23:7b:0b,set:range-hood,range-hood"
        "7e:cd:40:17:1b:37,set:seal,ipad-air3"
        "5a:ff:03:7b:d5:96,set:seal,mac-home"
        "00:1c:42:0e:63:eb,set:seal,mac-vm"
        "94:83:c4:a4:6e:e6,set:seal,gli-router"
        "f4:84:8d:9c:74:31,tplink"
        "84:46:93:e2:cb:20,mi-dehumidifier"
      ];
    };
  };
}