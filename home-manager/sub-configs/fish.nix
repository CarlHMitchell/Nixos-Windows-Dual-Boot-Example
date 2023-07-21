{ config, lib, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      direnv hook fish | source
      starship init fish | source
      set -x KTMR_DIRENV_SKIP_NIX_VERSION_CHECK "iknowwhatimdoing"
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
      ls = {
        body = "exa --color=auto --group-directories-first --classify $argv";
      };
      la = {
        body = "exa --color=auto --group-directories-first --classify --all $argv";
      };
      ll = {
        body = "exa --color=auto --group-directories-first --classify --all --long --header --group $argv";
      };
      aws_id = {
        body = "openssl x509 -in $argv -outform DER | sha256sum";
      };
      # Deep Fuzzy Change Directory.
      dfcd = {
        body = "br --only-folders --cmd  \"cd $argv\"";
      };
      fuck = {
        # https://github.com/nvbn/thefuck
        body = "eval (thefuck (history | head -n1))";
      };
      hex = {
        body = "hexdump -e '8/1 \"0x%02X, \"' $argv";
      };
      mkcd = {
        body = "mkdir -p $argv && cd $argv";
      };
      space = {
        body = ''
          btrfs fi df $argv[1]
          sudo btrfs fi usage $argv[1]
        '';
      };
      generations = {
        body = ''
          echo "boot generations" &&
          sudo nix-env -p /nix/var/nix/profiles/system/ --list-generations &&
          echo "system generations" &&
          nix-env --list-generations &&
          echo "home-manager generations" &&
          home-manager generations
        '';
      };
      sysupgrade = {
        body = ''
          sudo nixos-rebuild boot &&
          sudo nixos-rebuild switch &&
          home-manager switch &&
          generations &&
          space /
        '';
      };
      btrfsbalance = {
        body = ''
          for i in 0 5 10 15 20 25 30 40 50 60 70 80 90 100
            echo "btrfs balance: Running with $i% on $argv[1]"
            sudo btrfs balance start -dusage=$i -musage=$i $argv[1]
          end
        '';
      };
      spacesaver = {
        body = ''
          sudo nix-collect-garbage -d
          btrfsbalance /
          docker system prune --all
        '';
      };
      gitgc = {
        body = ''
          git prune
          rm "(git rev-parse --show-toplevel)/.git/gc.log"
          git gc
        '';
      };
      calc = {
        body = ''
          orpie
        '';
      };
    };
  };
}