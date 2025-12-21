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
    user = "fdisk";
    macSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";
  in {
    # MacOS Configuration: Run with `darwin-rebuild switch --flake .#macbook`
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = macSystem;
      specialArgs = {inherit emacs-overlay user ghostty-shaders;};
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [emacs-overlay.overlays.default];
          users.users.${user}.home = "/Users/${user}";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = ./home.nix;
            extraSpecialArgs = {inherit emacs-overlay user ghostty-shaders oh-my-tmux;};
          };
        }
      ];
    };

    # Arch Home Configuration: Run with `home-manager switch --flake .#arch`
    homeConfigurations.arch = home-manager.lib.homeManagerConfiguration {
      pkgs = npkgs.legacyPackages.${linuxSystem};
      modules = [./home.nix];
      extraSpecialArgs = {inherit emacs-overlay;};
    };
  };
}
