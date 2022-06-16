{
  description = "Nix Flake Templates";

  outputs = { self }: {
    templates = {
      rust = {
        path = ./rust;
        description = "Rust Development Environment";
      };
    };
  };
}
