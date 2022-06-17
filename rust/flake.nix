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
        # the current system, and derive a Rust Toolchain from the toolchain
        # file defined in the flake root.

        rustPkgs = fenix.packages.${system};
        rust = rustPkgs.fromToolchainFile {
          dir = ./.;
        };

        # VSCode - Use the base set of extensions for VSCode defined at system
        # level. Note that this makes the flake impure, and obviously relies on
        # being used within a very specific user environment! Define VSCode to
        # use the system base extensions, plus other standard packaged
        # extensions relevant (such as TOML support), plus the latest nightly
        # Rust Analyzer from the Fenix packages.

        vscodeExtensionsBase = import ~/.config/nix/software/vscode/extensions/all.nix { pkgs = pkgs; };
        vscode = pkgs.vscode-with-extensions.override {
          vscodeExtensions = vscodeExtensionsBase.extensions ++ (with pkgs.vscode-extensions; [
            bungcip.better-toml
          ]) ++ [
            rustPkgs.rust-analyzer-vscode-extension
          ];
        };

      in rec {
        devShells.default = pkgs.mkShell {

          # Inputs - provide the derived Rust toolchain, compiler dependencies,
          # and the configured VSCode with Rust specific extensions.

          buildInputs = with pkgs; [
            clang
            lld
            libiconv
            rust
            vscode
          ];

          # Cargo - set Cargo to use a local cache/build folder for hygiene.

          CARGO_HOME = "./.cargo";

          # Rust - set the Rust source path for the use of tooling such as Rust
          # Analyzer, etc.

          RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
        };
      }
    );
}
