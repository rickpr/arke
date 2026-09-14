{ pkgs, ... }: {
  home.packages = with pkgs; [
    fastfetch
    neovim
    ripgrep
    fd
    fzf
    jq
    direnv
    pnpm
    postgresql
    pnpm
    tmux
    inlyne
  ];
}
