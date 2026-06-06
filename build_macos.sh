cat arke.txt
sudo nix run --refresh --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ".#macbook" --show-trace
nix run --refresh --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- news --flake ".#macbook"
