{
  description = "Flake for packaging the cl-autowrap library.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cl-nix-lite.url = "github:hraban/cl-nix-lite";
    flake-utils.url = "github:numtide/flake-utils";
    autowrap = {
      url = "github:rpav/cl-autowrap";
      flake = false;
    };
    defpackagePlus = {
      url = "github:rpav/defpackage-plus";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, cl-nix-lite, flake-utils, autowrap, defpackagePlus }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system}.extend cl-nix-lite.overlays.default;
      inherit (pkgs.lispPackagesLite) lispDerivation lispMultiDerivation alexandria cffi cl-json
                                      cl-ppcre trivial-features;
      defpackage-plus = lispDerivation {
        src = defpackagePlus;
        lispDependencies = [ alexandria ];
        lispSystem = "defpackage-plus";
      };
      inherit (lispMultiDerivation {
        src = autowrap;
        buildInputs = with pkgs; [ libffi ];
        systems = {
          cl-autowrap = {
            lispDependencies = [ alexandria cffi cl-json cl-ppcre defpackage-plus trivial-features ];
          };
          cl-plus-c = {
            lispDependencies = [ cl-autowrap ];
          };
          cl-autowrap-test = {
            lispDependencies = [ cl-autowrap ];
          };
        };
      }) cl-autowrap cl-plus-c cl-autowrap-test;
    in {
      packages = {
        default = cl-autowrap;
        inherit cl-plus-c cl-autowrap-test;
      };
    });
}
