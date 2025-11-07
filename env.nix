{ config, lib, pkgs, ... }:

{
  environment.variables = {
    EDITOR = "vim";
    GOPROXY = "http://athens.router.i.home";
  };
}
