{
  description = "fdisk's Sovereign Config";

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
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, npkgs, darwin, home-manager, emacs-overlay, ... }: 
  let
    user = "fdisk";
    macSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";
  in {
    # MacOS Configuration: Run with `darwin-rebuild switch --flake .#macbook`
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = macSystem;
      specialArgs = { inherit emacs-overlay user; };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [ emacs-overlay.overlays.default ];
          users.users.fdisk.home = "/Users/fdisk";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.fdisk = ./home.nix;
          };
        }
      ];
    };

    # Arch Home Configuration: Run with `home-manager switch --flake .#arch`
    homeConfigurations.arch = home-manager.lib.homeManagerConfiguration {
      pkgs = npkgs.legacyPackages.${linuxSystem};
      modules = [ ./home.nix ];
      extraSpecialArgs = { inherit emacs-overlay; };
    };
  };
}
