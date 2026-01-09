<div align="center">

![Arke Logo](arke.png)

# ἀρχή (Arke)
### *First Principles for a Sovereign Developer Environment*
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

![Installation Demo](https://github.com/user-attachments/assets/0321e3a0-cfad-4e18-8ab8-f7840e654bd0)

</div>

---


## 🚀 Getting Started (macOS)

Arke uses **[Lix](https://lix.systems)**, a robust and independent Nix implementation. 

1. **Install Lix**  
   Follow the official instructions at [lix.systems/install](https://lix.systems/install).

2. **Clone this repository**
   ```bash
   git clone https://github.com/rickpr/arke.git
   cd arke
   ```

3. **Configure Variables**  
   Edit `variables.nix` to match your local system:
   ```nix
   {
     user = "your_user";
     fullName = "Your Name";
     email = "your@email.com";
     signingKey = "YOUR_GPG_KEY_ID";
     macHostname = "your_hostname";
     macSystem = "aarch64-darwin"; # or x86_64-darwin
   }
   ```

4. **Build and Switch**  
   Run the build script (requires sudo):
   ```bash
   chmod +x build_macos.sh
   ./build_macos.sh
   ```

## ❓ Why Arke?

Why use Nix/Lix instead of a standard Homebrew setup or a collection of Bash scripts?

| Feature | Arke (Nix/Lix) | Homebrew / Bash Scripts |
| :--- | :--- | :--- |
| **State** | **Declarative**: The code *is* the state. | **Imperative**: You hope the scripts ran correctly. |
| **Reliability** | **Atomic**: Builds either succeed or fail completely. | **Fragile**: Scripts can fail halfway, leaving a mess. |
| **Reproducibility** | **Identical**: Same config = same environment. | **Drift**: Versions drift over time across machines. |
| **Rollbacks** | **Instant**: Switch back to any previous generation. | **Manual**: Good luck undoing a broken script. |
| **Isolation** | **Sandboxed**: Packages don't bleed into each other. | **Global**: One update can break other dependencies. |

## 📦 Managing Dependencies

Arke splits dependency management between **Nix (Lix)** for CLI tools and development environments, and **Homebrew** for macOS-specific apps and casks.

### 1. CLI Tools (Nix)
Most of your terminal-based tools should go in `home.nix`.
- **File**: [`home.nix`](file:///Users/fdisk/arke/home.nix)
- **Key**: `home.packages`
- **Example**:
  ```nix
  home.packages = with pkgs; [
    ripgrep
    fd
    ffmpeg
    # Add your new tools here
  ];
  ```

### 2. macOS Apps & Binaries (Homebrew)
For things that are better managed via Brew (like GUI apps or specific Mac binaries), use `darwin.nix`.
- **File**: [`darwin.nix`](file:///Users/fdisk/arke/darwin.nix)
- **Keys**: `homebrew.brews` (CLI) and `homebrew.casks` (GUI)
- **Example**:
  ```nix
  homebrew = {
    brews = [ "xcodegen" ];
    casks = [ "ghostty" "postman" ];
  };
  ```

## ⚙️ Architecture

- **`flake.nix`**: The entry point, orchestrating outputs for macOS and Linux.
- **`variables.nix`**: Your centralized identity and hardware configuration.
- **`darwin.nix`**: macOS system-level settings and Homebrew integration.
- **`home.nix`**: Home Manager configuration (Git, Zsh, Bash, Emacs, Ghostty).
- **`common.nix`**: Shared packages across all platforms.

## 🛠️ Advanced Git
This setup includes **Git Delta** for beautiful, readable diffs and **zdiff3** for smarter conflict resolution.

## 💡 Tips & Gotchas

### 🚪 Escape Hatches
While this config aims to be comprehensive, you may need machine-specific tweaks:
- **Shells**: The config automatically sources `~/.zshrc_local` for Zsh or `~/.bashrc_local` for Bash if they exist.
- **Identity**: All personal identifiers is centralized in `variables.nix`.

### ⚠️ The "Clobbering" Problem
Home Manager will **fail** if it detects existing config files like `.zshrc` or `.emacs.d`.
- **Solution**: Before your first run, move existing config files to a backup (e.g., `mv ~/.zshrc ~/.zshrc_local`).

### 🛠️ Manual Interventions
- **Postgres**: Managed as a service, but may need manual initialization or starting (`brew services` or `pg_ctl`).
- **Ghostty Shaders**: Included via Git submodule and symlinked automatically.

## 🏛️ Principles

**ἀρχή** (Arke) means "first principle". This environment is built on:
1. **Reproducibility**: Built from source and logic, not ad-hoc commands.
2. **Simplicity**: Embracing "Worse is Better" for implementation simplicity.
3. **Sovereignty**: Free from corporate lock-in, preferring **[Lix](https://lix.systems)** for a community-driven experience.

## ⚖️ License

This project is released into the public domain via the [Unlicense](LICENSE).
