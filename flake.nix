{
  description = "Nix Flake Templates";

  outputs = { self }: {
    templates = {
      node = {
        path = ./node;
        description = "Node Development Environment";
      };
      rust = {
        path = ./rust;
        description = "Rust Development Environment";
      };
    };
  };
}
