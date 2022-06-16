{
  description = "Rust Development Environment";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
    utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, fenix, nixpkgs, utils }:
    utils.lib.eachSystem (with utils.lib.system; [
      aarch64-darwin
      aarch64-linux
      x86_64-darwin
      x86_64-linux
    ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        rust = fenix.packages.${system};
        vscodeSystem = import ~/.config/nix/software/vscode/extensions/all.nix { pkgs = pkgs; };
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust Toolchain
            rust.stable.toolchain

            # Compiler Dependencies
            clang
            lld
            libiconv

            # VSCode with Rust Extensions
            (vscode-with-extensions.override {
              vscodeExtensions = vscodeSystem.extensions ++ (with pkgs.vscode-extensions; [
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