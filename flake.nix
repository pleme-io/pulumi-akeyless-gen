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

        # Pulumi schema JSON structure validation
        checks.default = pkgs.runCommand "check-pulumi-gen" {
          src = self;
          nativeBuildInputs = [ pkgs.jq ];
        } ''
          cd $src
          JSON_COUNT=0
          FAIL=0
          for f in $(find . -name '*.json' -not -path './.git/*'); do
            JSON_COUNT=$((JSON_COUNT + 1))
            if ! jq empty "$f" 2>/dev/null; then
              echo "FAIL: $f is not valid JSON"
              FAIL=$((FAIL + 1))
            fi
          done
          if [ -f schema.json ]; then
            MISSING=""
            for field in name version resources; do
              if ! jq -e ".$field" schema.json >/dev/null 2>&1; then
                MISSING="$MISSING $field"
              fi
            done
            if [ -n "$MISSING" ]; then
              echo "FAIL: schema.json missing required fields:$MISSING"
              FAIL=$((FAIL + 1))
            fi
          fi
          if [ "$JSON_COUNT" -eq 0 ]; then
            echo "FAIL: no JSON files found"
            exit 1
          fi
          if [ "$FAIL" -gt 0 ]; then
            echo "FAIL: $FAIL validation errors"
            exit 1
          fi
          echo "OK: $JSON_COUNT JSON files pass validation"
          mkdir -p $out
          echo "pulumi-gen: $JSON_COUNT files checked" > $out/result.txt
        '';
      }
    );
}
