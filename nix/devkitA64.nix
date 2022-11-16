let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e3583ad6e533a9d8dd78f90bfa93812d390ea187.tar.gz") {};
  image = pkgs.dockerTools.pullImage {
    imageName = "devkitpro/devkita64";
    imageDigest = "sha256:70db4c954eea43be5f1bc64c8882154126c99f47927ecb1e6b27fa18004fc961";
    sha256 = "a05LU5jF5KxQdqWJv+4b3EBRlVCZjBGx69WpFL57wP4=";
    finalImageName = "devkitpro/devkita64";
    finalImageTag = "20221113";
  };
in {
  devkitA64 = pkgs.stdenv.mkDerivation {
    name = "devkitA64";
    src = import ./extract-docker.nix pkgs image;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc
      pkgs.ncurses6
      pkgs.zsnes
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitA64,libnx,portlibs,tools} $out
      rm -rf $out/pacman
    '';
  };
}
