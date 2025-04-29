# Solysis
An animal behavior and Calcium imaging analysis pipeline.
It's still in the early development stage so goodluck XD.

# Download
In a blank folder:
```console
git clone https://github.com/Solhvemjsun/Solysis
```

# Launching

## Using Nix package manager or NixOS (recommended)
In the folder
```console
nix-shell

```
You will enter the nix environment containing all the required package, and Jupyterlab will automatically launched in your default or activating browser.

## Using Conda
Import the conda environment (environment.yml) in your Conda shell (you only need to do this once).
```console
conda env create -f -n Solysis.yaml

```
Enter the environment:
```console
conda activate Solysis

```
Launching the jupyter-lab:
```console
jupyter-lab

```

## Using Anaconda client

Import the environment, activate it, then launch the jupyter-lab in the homepage.
