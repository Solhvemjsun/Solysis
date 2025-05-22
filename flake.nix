{
  description = "Flake for Solysis develop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { nixpkgs, ... }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShells."${pkgs.stdenv.hostPlatform.system}" = {
      "Solysis" = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          (python3.withPackages (python-pkgs: with python-pkgs; [
            requests
            numpy
            natsort
            tkinter
            jupyterlab
            matplotlib
            pandas
            scikit-learn
            torch
            scipy
            plotly
            ipympl
            mplcursors
            kaleido
          ]))
          # pkgs.texlive.combined.scheme-full
        ];
        shellHook = ''
          echo "Thanks for using Solysis, happy research!"
          jupyter-lab
        '';
      };
    };

  };
}
