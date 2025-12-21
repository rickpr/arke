{ config, pkgs, emacs-overlay, ... }: {
  home.username = "fdisk";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/fdisk" else "/home/fdisk";

  home.packages = with pkgs; [
    direnv
    gnupg
    nix-direnv
    ripgrep
    fd
    fzf
    pinentry_mac
    python314
  ];

  # Emacs-Plus for Mac / Emacs for Arch
  programs.emacs = {
    enable = true;
    package = if pkgs.stdenv.isDarwin 
              then pkgs.emacs-unstable # Use overlay for emacs-plus features
              else pkgs.emacs;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      [[ ! -f ~/.zshrc_local ]] || source ~/.zshrc_local
      eval "$(direnv hook zsh)"
    '';
 
    # 1. Enable Oh-My-Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "colored-man-pages" 
        "direnv"
      ] ++ (if pkgs.stdenv.isDarwin then [ "brew" "macos" ] else [ "archlinux" ]);
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };

  programs.zsh.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      core.editor = "nvim";
      credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "cache";
      user = {
        name = "fdisk";
        email = "ricardo@gaintain.co";
	signingkey = "90C13A2BD265293A";
      };
    };
  };

  # 2. Configure GPG
  programs.gpg = {
    enable = true;
    # settings = { ... }; # Optional: Add your keyserver or default-key here
  };

  # 3. Configure the Agent (This is the tricky part on Mac)
  # Home Manager's services.gpg-agent works on Linux, but on Mac,
  # it's better to manually link the config to point to pinentry-mac.
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    default-cache-ttl 600
    max-cache-ttl 7200
  '';

  home.stateVersion = "25.11";
}
