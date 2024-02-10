{
  description = "Nix Flakes";

  outputs = {self}: {
    templates = {
      default = self.rust;

      node = {
        path = ./node;
        description = "Node Development Environment";
      };

      rust = {
        description = "Rust Development Environment";
        path = ./rust;
        welcomeText = ''
          # Rust Development Template

          Intended as a quick starting point for new Rust projects. It is
          expected that the flake will be expanded to include any other needed
          dependencies, tools, etc.
        '';
      };
    };
  };
}
