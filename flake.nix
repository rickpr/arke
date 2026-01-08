{
  description = "ἀρχή - First Principles for a developer's Arch and macOS configurations";

  inputs = {
    npkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "npkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "npkgs";
    };

    oh-my-tmux = {
      url = "github:gpakosz/.tmux";
      flake = false;
    };

    ghostty-shaders = {
      url = "github:0xhckr/ghostty-shaders";
      flake = false;
    };

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = {
    self,
    npkgs,
    darwin,
    home-manager,
    emacs-overlay,
    ghostty-shaders,
    oh-my-tmux,
    ...
  }: let
    vars = import ./variables.nix;
  in {
    # MacOS Configuration: Run with `darwin-rebuild switch --flake .#macbook`
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = vars.macSystem;
      specialArgs = {inherit emacs-overlay ghostty-shaders vars; user = vars.user;};
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [emacs-overlay.overlays.default];
          users.users.${vars.user}.home = "/Users/${vars.user}";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${vars.user} = ./home.nix;
            extraSpecialArgs = {inherit emacs-overlay ghostty-shaders oh-my-tmux vars; user = vars.user;};
          };
        }
      ];
    };

    # Arch Home Configuration: Run with `home-manager switch --flake .#arch`
    homeConfigurations.arch = home-manager.lib.homeManagerConfiguration {
      pkgs = npkgs.legacyPackages.${vars.linuxSystem};
      modules = [./home.nix];
      extraSpecialArgs = {inherit emacs-overlay vars; user = vars.user;};
    };
  };
}
