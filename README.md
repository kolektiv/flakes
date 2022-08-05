# Flakes

Personal Nix Flake templates for simple, isolated development environments.

## Usage

To initialise a project with an available template:

```shell
> nix flake init -t "github:kolektiv/flakes#<TEMPLATE>"
```

To view available templates:

```shell
> nix flake show "github:kolektiv/flakes"
```

These will only work on a system with Nix Flakes enabled, obviously!
