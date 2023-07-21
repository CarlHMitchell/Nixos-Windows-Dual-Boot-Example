{ config, lib, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)" # TODO: Remove line if you removed `starship` from your programs.
      eval "$(direnv hook bash)" # TODO: Remove line if you removed `direnv` from your programs.
      eval "$(thefuck --alias)" # TODO: Remove line if you removed `thefuck` from your programs.
    '';
    shellAliases = rec {
      ls = "exa --color=auto --group-directories-first --classify"; # TODO: Change/remove if you removed `exa` from your programs
      la = "${ls} --all";
      ll = "${ls} --all --long --header --group";
    };
  };
}
