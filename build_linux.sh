#!/usr/bin/env bash

echo "Building Arke for Arch Linux..."
cat arke.txt
nix run --refresh --extra-experimental-features nix-command --extra-experimental-features flakes home-manager -- switch --flake ".#linux" --show-trace
