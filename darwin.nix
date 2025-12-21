{ pkgs, config, ... }: {
  imports = [ ./common.nix ];
  system.primaryUser = "fdisk";

  environment.systemPackages = [
    pkgs.neovim
    pkgs.pinentry_mac
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # "zap" means Nix will UNINSTALL anything not in this list
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    # Mac App Store apps (optional, needs 'mas' installed)
    # masApps = { "Xcode" = 497799835; };

    # taps = [ "d12frosted/emacs-plus" ]; # If you decide to go Brew for Emacs too
    
    # CLI tools via Brew (only if Nix version is broken)
    # brews = [ "cocoapods" ];

    casks = [
      "ghostty"
    ];
  };
  
  # The NS Settings (Autocorrect Kill-switch)
  system.defaults.NSGlobalDomain = {
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
  };

  system.activationScripts.postActivation.text = ''
    echo "Syncing Nix Apps..." >&2
    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"
    
    # Define paths to search
    # 1. System-wide Apps
    # 2. User-profile Apps (Home Manager)
    paths=(
      "/run/current-system/sw/Applications"
      "/etc/profiles/per-user/fdisk/Applications"
    )

    for src in "''${paths[@]}"; do
      if [ -d "$src" ]; then
        find "$src" -maxdepth 1 -type l -exec cp -R {} "/Applications/Nix Apps/" \;
      fi
    done
  '';


  # Native Postgres setup
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };

  networking.computerName = "juno"; # The "Human" name (AirDrop, Finder)
  networking.hostName = "juno"; # The DNS name (Terminal, SSH)
  networking.localHostName = "juno"; # The Bonjour name (.local)

  system.stateVersion = 5;
}
