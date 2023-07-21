{ config, lib, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source # TODO: Remove line if you removed `direnv` from your programs
      starship init fish | source # TODO: Remove line if you removed `starship` from your programs.
    '';
    plugins = [
      # Oh-my-fish plugins are stored in their own repos, which makes them easy to import
      {
        name = "bass";
        src = fetchGit {
          url = "https://github.com/edc/bass.git";
          rev = "7aae6a85c24660422ea3f3f4629bb4a8d30df3ba";
          ref = "master";
        };
      }
    ];
    functions = {
      # TODO: Change these if you don't have exa
      ls = {
        body = "exa --color=auto --group-directories-first --classify $argv";
      };
      la = {
        body = "exa --color=auto --group-directories-first --classify --all $argv";
      };
      ll = {
        body = "exa --color=auto --group-directories-first --classify --all --long --header --group $argv";
      };
      # Deep Fuzzy Change Directory. TODO: Remove if you don't have broot
      dfcd = {
        body = "br --only-folders --cmd  \"cd $argv\"";
      };
      fuck = { # TODO: Remove if you don't have `thefuck`
        # https://github.com/nvbn/thefuck
        body = "eval (thefuck (history | head -n1))";
      };
      hex = {
        body = "hexdump -e '8/1 \"0x%02X, \"' $argv";
      };
      mkcd = {
        body = "mkdir -p $argv && cd $argv";
      };
      generations = {
        body = ''
          echo "boot generations" &&
          sudo nix-env -p /nix/var/nix/profiles/system/ --list-generations &&
          echo "system generations" &&
          nix-env --list-generations
        '';
      };
      gitgc = {
        body = ''
          git prune
          rm "(git rev-parse --show-toplevel)/.git/gc.log"
          git gc
        '';
      };
      calc = { # TODO: Remove if you don't have orpie
        body = ''
          orpie
        '';
      };
    };
  };
}
