{
  inputs = {
    # keep-sorted start block=yes
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        purescript-overlay.follows = "";
        pyproject-nix.follows = "";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "";
        gitignore.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    # this is the lastest nixpkgs commit compatible dream2nix (nixpkgs#410058)
    # TODO stop pinning nixpkgs after dream2nix#1102 is merged
    nixpkgs.url = "github:NixOS/nixpkgs/bb22459c291dc8bb802fe259163213ffe1919042"; # NOTE sync this with your system's nixpkgs
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, inputs, ... }:
      {
        imports = [
          inputs.git-hooks-nix.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        systems = lib.systems.flakeExposed;

        perSystem =
          {
            pkgs,
            config,
            lib,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ ];
              config = {
                allowUnfree = true;
              };
            };

            packages = {
              default = inputs.dream2nix.lib.evalModules {
                packageSets.nixpkgs = pkgs;
                modules = [
                  ./package.nix
                  {
                    paths = {
                      projectRoot = ./.;
                      projectRootFile = "flake.nix";
                      package = ./.;
                    };
                  }
                ];
              };
            };

            devShells.default = pkgs.mkShellNoCC {
              inputsFrom = [
                config.treefmt.build.devShell
                config.pre-commit.devShell
              ];
              packages =
                let
                  myPkg = config.packages.default;
                  inherit (myPkg.config.deps) python;
                  pythonWithMyPkg = (python.withPackages (_: [ myPkg.out ])).override {
                    ignoreCollisions = true;
                  };
                in
                [ pythonWithMyPkg ]
                ++ builtins.attrValues {
                  inherit (python.pkgs)
                    # dev tools not written in python go here
                    black
                    ;
                }
                ++ builtins.attrValues {
                  inherit (pkgs)
                    # dev tools not written in python go here
                    ruff
                    ;
                };

              # upstream recommended config
              # https://github.com/flatironinstitute/CaImAn/blob/881e627adf951dde25d3839953c98acf6b4adab0/README.md?plain=1#L68
              MKL_NUM_THREADS = 1;
              OPENBLAS_NUM_THREADS = 1;
              VECLIB_MAXIMUM_THREADS = 1;
              OMP_NUM_THREADS = 1;
              KERAS_BACKEND = "tensorflow";
              TF_CPP_MIN_LOG_LEVEL = 2;
              CAIMAN_RELEASE = 1;

              # GPU
              # command to find needed libs: TF_CPP_MAX_VLOG_LEVEL=2 python -c "import tensorflow as tf; print(len(tf.config.list_physical_devices('GPU')))"
              LD_LIBRARY_PATH = lib.concatStringsSep ":" [
                "/run/opengl-driver/lib" # gpu driver path of NixOS
                (lib.makeLibraryPath [
                  pkgs.cudaPackages_12.cudatoolkit
                  pkgs.cudaPackages_12.cudnn_8_9
                  # pkgs.cudaPackages_11.tensorrt_8_6 # uncomment this to use tensorrt
                ])
              ];
            };

            pre-commit = {
              settings.hooks = {
                markdownlint.enable = true;
                treefmt.enable = true;
              };
            };

            treefmt = {
              programs = {
                deadnix.enable = true;
                nixf-diagnose.enable = true;
                nixfmt.enable = true;
                statix.enable = true;
              };

              programs.keep-sorted.enable = true;
            };
          };
      }
    );
}
