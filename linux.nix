{ pkgs, ... }: {
  home.packages = [
    pkgs.nerd-fonts.inconsolata
    pkgs.nerd-fonts.symbols-only
  ];
}
