{
  lib,
  dream2nix,
  config,
  ...
}:

let
  pyproject = lib.importTOML (config.mkDerivation.src + /pyproject.toml);
in
{
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps =
    { nixpkgs, ... }:
    {
      # Upstream constraint contains python <= 3.12 and tensorflow < 2.16. tensorflow < 2.16 implies python <= 3.11
      # https://github.com/flatironinstitute/CaImAn/blob/881e627adf951dde25d3839953c98acf6b4adab0/environment.yml#L4
      # https://github.com/flatironinstitute/CaImAn/blob/881e627adf951dde25d3839953c98acf6b4adab0/pyproject.toml#L44
      python = nixpkgs.python311;

      inherit (nixpkgs)
        # keep-sorted start
        fetchFromGitHub
        fetchpatch
        pcsclite
        qt6
        speechd
        writableTmpDirAsHomeHook
        # keep-sorted end
        ;
    };

  inherit (pyproject.project) name;
  version = "1.12.1";

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "flatironinstitute";
      repo = "CaImAn";
      tag = "v${config.version}";
      hash = "sha256-AHbaca5FWl//nZWFeCjNLibUgajwHh24WR4Qdo+kj+g=";
    };
    nativeBuildInputs = [ config.deps.writableTmpDirAsHomeHook ];
  };

  buildPythonPackage = {
    pyproject = true;
    pythonImportsCheck = [ "caiman" ];
  };

  pip = {
    pipVersion = "25.1.1";
    requirementsList =
      pyproject.build-system.requires
      ++ pyproject.project.dependencies
      ++ pyproject.project.optional-dependencies.jupyter;
    flattenDependencies = true;
    overrides = {
      tensorflow-io-gcs-filesystem = {
        env.autoPatchelfIgnoreMissingDeps = [ "libtensorflow_framework.so*" ]; # break circular dependency
      };
      pyside6-essentials = {
        mkDerivation.buildInputs = builtins.attrValues {
          inherit (config.deps.qt6)
            # keep-sorted start
            qt3d
            qtscxml
            qtvirtualkeyboard
            qtwayland
            qtwebengine
            # keep-sorted end
            ;
        };
        env = {
          dontWrapQtApps = true;
          autoPatchelfIgnoreMissingDeps = [
            # keep-sorted start
            "libQt6EglFsKmsGbmSupport.so*" # no pkg in Nixpkgs provides this
            "libmimerapi.so*" # no pkg in Nixpkgs provides this
            "libmysqlclient.so*" # probably we do not needed this
            # keep-sorted end
          ];
        };
      };
      pyside6-addons = {
        mkDerivation.buildInputs = builtins.attrValues {
          inherit (config.deps)
            # keep-sorted start
            pcsclite
            speechd
            # keep-sorted end
            ;
        };
        env = {
          dontWrapQtApps = true;
          autoPatchelfIgnoreMissingDeps = [
            # keep-sorted start
            "libQt63DQuickLogic.so*" # no pkg in Nixpkgs provides this
            # keep-sorted end
          ];
        };
      };
    };

    # TODO remove this when pyneb > 3.0.0
    pipFlags = [
      "--no-binary"
      "pynwb"
    ];
    overrides.pynwb = {
      mkDerivation.patches = [
        (config.deps.fetchpatch {
          name = "fix-cache-location.patch";
          url = "https://github.com/NeurodataWithoutBorders/pynwb/commit/ddfc02112ca2000502504fc48a0f5dfb7fb8db7a.patch";
          hash = "sha256-p2tYurkvAk21ljB5JLkf87jZTC+G7dFnXkOHNFBsjjA=";
        })
      ];

      mkDerivation = {
        nativeBuildInputs = [
          config.deps.python.pkgs.hatch-vcs
          config.deps.python.pkgs.hatchling
        ];
        propagatedBuildInputs = [
          config.pip.drvs.platformdirs.public
        ];
      };

      buildPythonPackage.pyproject = true;
    };
  };
}
