#!/usr/bin/env bash

echo "Building Arke for Arch Linux..."
cat arke.txt
nix run --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- switch --flake ".#linux" --show-trace
nix run --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- news --flake ".#linux"
