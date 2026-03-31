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
    ffmpeg
    gnupg
    ktlint
    libtool
    nix-direnv
    ripgrep
    fd
    fzf
    netlify-cli
    nodejs
    nodePackages.firebase-tools
    nodePackages.stylelint
    nodePackages.js-beautify
    openssl
    opencode
    pandoc
    pinentry_mac
    pkg-config
    python314
    shellcheck
    uv

    (writeShellScriptBin "gls" "exec ${coreutils}/bin/ls \"$@\"")
  ];

  programs = {
    # Emacs-Plus for Mac / Emacs for Arch
    emacs = {
      enable = true;
      package =
        if pkgs.stdenv.isDarwin
        then pkgs.emacs-unstable # Use overlay for emacs-plus features
        else pkgs.emacs;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    java = {
      enable = true;
      package = pkgs.jdk;
    };

    zsh = {
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
        NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
        PATH = "$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.config/emacs/bin:$PATH";
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      shellAliases = {
        ls = "gls --color=auto";
        ll = "ls -laF --color=auto";
        la = "ls -A --color=auto";
        l = "ls -CF --color=auto";
        vim = "nvim";
        vi = "nvim";
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        [[ ! -f ~/.bashrc_local ]] || source ~/.bashrc_local
        eval "$(direnv hook bash)"
      '';
      shellAliases = config.programs.zsh.shellAliases;
      sessionVariables = config.programs.zsh.sessionVariables;
    };

    git = {
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

    gpg = {
      enable = true;
    };
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
