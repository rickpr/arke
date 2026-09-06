sudo nix develop --extra-experimental-features nix-command --extra-experimental-features flakes . --command darwin-rebuild switch --flake ".#macbook" --show-trace
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes . --command home-manager news --flake ".#macbook" 2>/dev/null | awk -v RS='' '/\[unread\]/'
