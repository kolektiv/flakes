# Rust Development Flake

# A simple flake for Rust development (not build or packaging at this stage)
# providing Rust and a configured VSCode.

# Uses:

# Fenix: https://github.com/nix-community/fenix
# Flake Utils: https://github.com/numtide/flake-utils

{
  description = "Rust Development Environment";

  inputs = {

    # Fenix - Use the Fenix package source for contemporary Rust builds and
    # associated tooling such as the Rust Analyzer VSCode extension.

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, fenix, nixpkgs, utils }:
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

        # Rust - Use the appropriate set of packages provided by Fenix based on
        # the current system.

        rust = fenix.packages.${system};
        rustToolchain = rust.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = rust.lib.fakeSha256;
        };

        # VSCode - Use the base set of extensions for VSCode defined at system
        # level. Note that this makes the flake impure, and obviously relies on
        # being used within a very specific user environment!

        vscode = import ~/.config/nix/software/vscode/extensions/all.nix { pkgs = pkgs; };

      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust Toolchain
            rustToolchain.toolchain

            # Compiler Dependencies
            clang
            lld
            libiconv

            # VSCode with Rust Extensions
            (vscode-with-extensions.override {
              vscodeExtensions = vscode.extensions ++ (with pkgs.vscode-extensions; [
                bungcip.better-toml
              ]) ++ [
                rust.rust-analyzer-vscode-extension
              ];
            })
          ];

          CARGO_HOME = "./.cargo";
        };
      }
    );
}