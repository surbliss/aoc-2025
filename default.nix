{ pkgs, ... }:
{
  packages = with pkgs; [
    zig
    zls
  ];

  # inputsFrom = with pkgs;[ ];

  env = {
    IS_NIX_SHELL = true;
  };

  shellHook = ''
    echo Hello!
  '';
}
