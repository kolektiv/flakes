# Node Development Flake

# A simple flake for Node development (not build or packaging at this stage)
# providing Node and a configured VSCode.

{
  description = "Node Development Environment";

  inputs = {

    # Nixpkgs - Use the unstable channel for packages.

    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };

    # Flake Utils - Use the Flake Utils tools to simplify the overall Nix
    # expression while still supporting likely systems.

    utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, utils }:
    let

      # Systems - Support only a subset of the default systems defined by the
      # Flake Utils tool - i686 isn't relevant and doesn't support half of the
      # relevant packages either.

      systems = with utils.lib.system; [
        aarch64-darwin
        aarch64-linux
        x86_64-darwin
        x86_64-linux
      ];

    in utils.lib.eachSystem systems (system:
      let

        # Packages - Import (and inherit current system) while also applying
        # configuration to allow unfree packages such as VSCode.

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        # VSCode - Use the base set of extensions for VSCode defined at system
        # level. Note that this makes the flake impure, and obviously relies on
        # being used within a very specific user environment! Define VSCode to
        # use the system base extensions, plus other standard packaged
        # extensions relevant.

        vscodeExtensionsBase = import ~/.config/nix/software/vscode/extensions/all.nix { pkgs = pkgs; };
        vscode = pkgs.vscode-with-extensions.override {
          vscodeExtensions = vscodeExtensionsBase.extensions ++ (with pkgs.vscode-extensions; [
            # <EXTENSIONS>
          ]);
        };

      in rec {
        devShells.default = pkgs.mkShell {

          # Inputs - provide the standard NodeJS LTS package and any supporting
          # packages required.

          buildInputs = with pkgs; [
            nodejs-16_x
          ];

          # Shell Hook - set environment variables to configure the behaviour of
          # configured build inputs, etc.

          # Define a local NPM (.npm) path

          shellHook = ''
            export NPM=$PWD/.npm
          '' 
          
          # Configure NPM to have a local prefix, and local cache location
          # within the prefix structure.

        + ''
            export NPM_CONFIG_CACHE=$NPM/cache
            export NPM_CONFIG_PREFIX=$NPM
          ''

          # Set the NODE_PATH to include the prefix NPM install.

        + ''
            export NODE_PATH=$NPM_CONFIG_PREFIX:$NODE_PATH
          ''

          # Set the PATH to include the /[.]bin directories of both the prefix
          # (global) location, and the local modules (local with higher
          # precedence than global, global should be used rarely with this
          # approach).

        + ''
            export PATH=$PWD/node_modules/.bin:$NPM_CONFIG_PREFIX/bin:$PATH
          '';
        };
      }
    );
}
