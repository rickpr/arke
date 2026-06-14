{pkgs, ...}: {
  home.packages = with pkgs; [
    postgresql
    tmux
  ];
}
