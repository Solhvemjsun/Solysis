let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
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
    echo "Welcome to AfterDLC!"
    echo "Type 'jupyter-lab to open the develop env"
  '';
}
