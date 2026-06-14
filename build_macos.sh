sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ".#macbook" --show-trace
nix run --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- news --flake ".#macbook" 2>/dev/null | awk -v RS='' '/\[unread\]/'
