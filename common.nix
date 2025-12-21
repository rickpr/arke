{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    ripgrep
    fd
    fzf
    jq
    direnv
    postgresql_17
    tmux
  ];
}
