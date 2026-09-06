#!/usr/bin/env bash
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes . --command home-manager switch --flake ".#linux" --show-trace
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes . --command home-manager news --flake ".#linux" 2>/dev/null | awk -v RS='' '/\[unread\]/'
