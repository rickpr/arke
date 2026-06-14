{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fastfetch
    neovim
    ripgrep
    fd
    fzf
    jq
    direnv
    postgresql
    tmux
  ];
}
