{pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e3583ad6e533a9d8dd78f90bfa93812d390ea187.tar.gz") {}}:
with pkgs.buildPackages;
pkgs.mkShell {
  buildInputs = [ zig ];
  shellHook = ''
    export DEVKITPRO="result"
  '';
}
