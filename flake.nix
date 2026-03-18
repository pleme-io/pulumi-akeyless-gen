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
          find $src -name '*.json' -not -path '*/.git/*' -exec cp {} $out/share/pulumi/ \;
          touch $out/share/pulumi/.generated
        '';

        checks.default = pkgs.runCommand "check-pulumi-gen" { src = self; } ''
          cd $src
          count=$(find . -name '*.json' -not -path './.git/*' | wc -l | tr -d ' ')
          if [ "$count" -eq 0 ]; then echo "FAIL: no JSON files found"; exit 1; fi
          echo "OK: $count JSON files found"
          mkdir -p $out && echo "$count files" > $out/result.txt
        '';
      }
    );
}
