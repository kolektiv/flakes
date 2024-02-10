{
  description = "Nix Flakes";

  outputs = {self}: {
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
