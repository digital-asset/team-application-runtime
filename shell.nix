# Update nixpkgs with:
# nix-shell -p niv --run "niv update"

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
pkgs.mkShell {
  buildInputs = [
    pkgs.bash
    pkgs.curl
    pkgs.git
    pkgs.gnupg
    pkgs.google-cloud-sdk
    (pkgs.sbt.override { jre = pkgs.jdk11; })
    (pkgs.terraform_1.withPlugins (p: with p; [
      google
    ]))
  ];
}
