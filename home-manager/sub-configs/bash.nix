{ config, lib, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"
      eval "$(direnv hook bash)"
      eval "$(thefuck --alias)"
      eval "$(/home/carl/nixfiles/home/bin/load-ktmr.sh)"
      export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
      export KTMR_PATH="/home/carl/code/KeepTruckin/kt"
    '';
    shellAliases = rec {
      ls = "exa --color=auto --group-directories-first --classify";
      la = "${ls} --all";
      ll = "${ls} --all --long --header --group";
    };
  };
}