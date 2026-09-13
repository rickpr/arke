{ pkgs, ... }: {
  home.packages = with pkgs; [
    fastfetch
    neovim
    ripgrep
    fd
    fzf
    jq
    direnv
    postgresql
    pnpm
    tmux
    inlyne
  ];
}
