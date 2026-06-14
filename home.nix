{
  config,
  lib,
  pkgs,
  ghostty-shaders,
  oh-my-tmux,
  user,
  vars,
  ...
}:
{
  home.username = user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";

  home.packages =
    with pkgs;
    [
      cmake
      coreutils
      delta
      direnv
      dolt
      fontconfig
      ffmpeg
      gnupg
      jq
      ktlint
      libtool
      nix-direnv
      ripgrep
      fd
      fzf
      gh
      netlify-cli
      nodejs
      firebase-tools
      stylelint
      js-beautify
      openssl
      opencode
      p7zip
      pandoc
      pkg-config
      python314
      shellcheck
      uv

      (writeShellScriptBin "gls" "exec ${coreutils}/bin/ls \"$@\"")
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      pinentry_mac
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      neovim
      tmux
      pinentry-gtk2
    ];

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs;
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
      enableCompletion = true;

      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        ignoreSpace = true; # a leading space keeps a command out of history
        share = true;
        extended = true;
      };

      initContent = ''
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        [[ ! -f ~/.zshrc_local ]] || source ~/.zshrc_local

        bindkey -v
        KEYTIMEOUT=1 # 10ms, so Esc into normal mode feels instant

        # Ctrl+R / Ctrl+S: incremental history search, backward / forward.
        # stty frees Ctrl+S from terminal flow control (XOFF) so zle gets it.
        stty -ixon 2>/dev/null
        bindkey -M viins '^R' history-incremental-pattern-search-backward
        bindkey -M viins '^S' history-incremental-pattern-search-forward
        bindkey -M vicmd '^R' history-incremental-pattern-search-backward
        bindkey -M vicmd '^S' history-incremental-pattern-search-forward

        setopt interactive_comments auto_cd extended_glob

        # Case-insensitive completion with an arrow-navigable, colored menu.
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # zsh leaves these unbound by default:
        bindkey '^[[H'  beginning-of-line # Home
        bindkey '^[[F'  end-of-line       # End
        bindkey '^[OH'  beginning-of-line # Home (application cursor mode)
        bindkey '^[OF'  end-of-line       # End  (application cursor mode)
        bindkey '^[[1~' beginning-of-line # Home (vt/linux console)
        bindkey '^[[4~' end-of-line       # End  (vt/linux console)
        bindkey '^[[3~' delete-char       # Delete
      '';

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
        credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "cache";
        core = {
          editor = "nvim";
          pager = "delta";
          excludesFile = "~/.gitignore";
        };
        interactive.diffFilter = "delta --color-only";
        delta.navigate = true;
        merge.conflictStyle = "zdiff3";
        user = {
          name = vars.fullName;
          email = vars.email;
          signingkey = vars.signingKey;
        };
        commit.gpgsign = true;
      };
    };

    gpg = {
      enable = true;
    };
  };

  # 3. Configure the Agent
  # On Linux, home-manager manages the gpg-agent service via systemd.
  # On Mac, it's better to manually write the config pointing to pinentry-mac.
  services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultCacheTtl = 600;
    maxCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-gtk2;
  };

  home.file = {
    ".gnupg/gpg-agent.conf" = lib.mkIf pkgs.stdenv.isDarwin {
      text = ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
        default-cache-ttl 600
        max-cache-ttl 7200
      '';
    };

    ".emacs.d".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/emacs";

    # The local overrides MUST be in the root of home as .tmux.conf.local
    ".tmux.conf".source = "${oh-my-tmux}/.tmux.conf";
    ".tmux.conf.local".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/arke/dotfiles/tmux.conf.local";
  };
  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/arke/dotfiles/ghostty-config";
  xdg.configFile."ghostty/shaders".source = ghostty-shaders;

  home.stateVersion = "25.11";
}
