{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    initExtra = ''
      eval "$(starship init zsh)"
      eval "$(direnv hook zsh)"
      eval "$(thefuck --alias)"
      export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
      eval "$(/home/carl/nixfiles/home/bin/load-ktmr.sh)"
      ## Keybindings section
      bindkey -e
      bindkey '^[[7~' beginning-of-line                               # Home key
      bindkey '^[[H' beginning-of-line                                # Home key
      if [[ "''${terminfo[khome]}" != "" ]]; then
      bindkey "''${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
      fi
      bindkey '^[[8~' end-of-line                                     # End key
      bindkey '^[[F' end-of-line                                     # End key
      if [[ "''${terminfo[kend]}" != "" ]]; then
      bindkey "''${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
      fi
      bindkey '^[[2~' overwrite-mode                                  # Insert key
      bindkey '^[[3~' delete-char                                     # Delete key
      bindkey '^[[C'  forward-char                                    # Right key
      bindkey '^[[D'  backward-char                                   # Left key
      bindkey '^[[5~' history-beginning-search-backward               # Page up key
      bindkey '^[[6~' history-beginning-search-forward                # Page down key
      # Navigate words with ctrl+arrow keys
      bindkey '^[Oc' forward-word                                     #
      bindkey '^[Od' backward-word                                    #
      bindkey '^[[1;5D' backward-word                                 #
      bindkey '^[[1;5C' forward-word                                  #
      bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
    '';

    shellAliases = rec {
      ls = "exa --color=auto --group-directories-first --classify";
      la = "${ls} --all";
      ll = "${ls} --all --long --header --group";
    };
  };
}