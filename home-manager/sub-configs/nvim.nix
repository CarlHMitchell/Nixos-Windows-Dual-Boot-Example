{ config, lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    coc = {
      enable = true;
    };
    # https://github.com/theniceboy/nvim
    # https://github.com/mattmc3/neovim-cheatsheet
    # https://docs.google.com/spreadsheets/d/19l4rQdYZfqpMtdTjvCrYLF2z9OsAqahhPunnw7I831s/edit#gid=589401919
    extraConfig = ''
      noremap E J
      noremap n j
      noremap e l
      noremap K N
      noremap k n
      noremap J E
      noremap j e
      noremap N K
      noremap l k
    '';
  };
}
