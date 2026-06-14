#!/usr/bin/env bash
nix run --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- switch --flake ".#linux" --show-trace
nix run --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- news --flake ".#linux" 2>/dev/null | awk -v RS='' '/\[unread\]/'
