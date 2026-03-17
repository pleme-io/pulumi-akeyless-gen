{
  description = "Generated Pulumi schema for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.runCommand "pulumi-akeyless-gen" {
          src = self;
        } ''
          mkdir -p $out/share/pulumi
          find $src -name '*.json' -exec cp {} $out/share/pulumi/ \;
          touch $out/share/pulumi/.generated
        '';
      }
    );
}
