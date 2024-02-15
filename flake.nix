{
  description = "Nix Flakes";

  outputs = {self}: {
    templates = {
      default = self.rust;

      elixir = {
        description = "Elixir Development Environment";
        path = ./elixir;
        welcomeText = ''
          # Elixir Development Template

          Intended as a quick starting point for new Elixir projects. It is
          expected that the flake will be expanded to include any other needed
          dependencies, tools, etc.
        '';
      };

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
