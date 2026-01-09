{
  config,
  pkgs,
  emacs-overlay,
  ghostty-shaders,
  oh-my-tmux,
  user,
  vars,
  ...
}: {
  home.username = user;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${user}"
    else "/home/${user}";

  home.packages = with pkgs; [
    cmake
    coreutils
    delta
    direnv
    fontconfig
    gnupg
    ktlint
    libtool
    nix-direnv
    ripgrep
    fd
    fzf
    nodejs
    nodePackages.firebase-tools
    nodePackages.stylelint
    nodePackages.js-beautify
    openssl
    pandoc
    pinentry_mac
    pkg-config
    python314
    shellcheck
    uv

    (writeShellScriptBin "gls" "exec ${coreutils}/bin/ls \"$@\"")
  ];

  # Emacs-Plus for Mac / Emacs for Arch
  programs.emacs = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.emacs-unstable # Use overlay for emacs-plus features
      else pkgs.emacs;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true; # Suggests commands as you type (gray text)
    syntaxHighlighting.enable = true; # Colors commands as you type (red/green)

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      [[ ! -f ~/.zshrc_local ]] || source ~/.zshrc_local
      eval "$(direnv hook zsh)"
    '';

    # 1. Enable Oh-My-Zsh
    oh-my-zsh = {
      enable = true;
      plugins =
        [
          "git"
          "sudo"
          "docker"
          "colored-man-pages"
          "direnv"
        ]
        ++ (
          if pkgs.stdenv.isDarwin
          then ["brew" "macos"]
          else ["archlinux"]
        );
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    sessionVariables = {
      PATH = "$HOME/.local/bin:$HOME/.config/emacs/bin:$PATH";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shellAliases = {
      ls = "gls --color=auto";
      ll = "ls -laF --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";
    };
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
      credential.helper =
        if pkgs.stdenv.isDarwin
        then "osxkeychain"
        else "cache";
      core = {
        editor = "nvim";
        pager = "delta";
      };
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      merge.conflictStyle = "zdiff3";
      user = {
        name = vars.fullName;
        email = vars.email;
        signingkey = vars.signingKey;
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
  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      default-cache-ttl 600
      max-cache-ttl 7200
    '';

    ".emacs.d".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/emacs";

    # The local overrides MUST be in the root of home as .tmux.conf.local
    ".tmux.conf".source = "${oh-my-tmux}/.tmux.conf";
    ".tmux.conf.local".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/arke/dotfiles/tmux.conf.local";
  };
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/arke/dotfiles/ghostty-config";
  xdg.configFile."ghostty/shaders".source = ghostty-shaders;

  home.stateVersion = "25.11";
}
