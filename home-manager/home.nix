# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # Impermanence module to manage persistent state
    inputs.impermanence.nixosModules.home-manager.impermanence

    # You can also split up your configuration and import pieces of it here:
    ./sub-configs/nvim.nix
    ./sub-configs/git.nix
    ./sub-configs/xcompose.nix
    ./sub-configs/fish.nix
    ./sub-configs/bash.nix
    ./sub-configs/zsh.nix
    ./sub-configs/plasma.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "USER"; # TODO: Set your user
    homeDirectory = "/home/USER"; # TODO: Set your user
    
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";

  # Add stuff for your user as you see fit:
  home = {
    persistence."/home/persist/USER" = { # TODO: Set your user
      directories = [
        ".ssh"
        "Downloads"
        "Documents"
        "Pictures"
        "code"
        "Music"
        "Videos"
        "Sync"
        # You may want to add some of the XDG directories here (see below)
      ];
      files = [];
      allowOther = true;
    };

    # These are some of my packages which are generally useful (IMO).
    # Add or remove as you see fit, though a few are referenced in sub-configs
    packages = with pkgs; [
      vscode-fhs
      vscode-extensions.bbenoist.nix
      vscode-extensions.timonwong.shellcheck
      vscode-extensions.arrterian.nix-env-selector
      vscode-extensions.mkhl.direnv
      vscode-extensions.jnoortheen.nix-ide
      libsForQt5.kdeconnect-kde
      libsForQt5.kdenlive
      steam # Includes Proton, allows running more Windows programs than WINE
      proton-caller
      python3
      broot # CLI directory traversal
      thefuck # CLI command correction
      minicom # Serial communications & more
      fzf # Fuzzy Find
      fishPlugins.foreign-env
      fishPlugins.fzf-fish
      b3sum # Fast, secure checksum
      black # Python linter
      shellcheck # Shell script linter
      fd # Great `find` replacement
      ripgrep # Great `grep` replacement
      exa # Great `ls` replacement
      vlc # Media player
      nix-index # Find what package in the Nix store provides an output file
      any-nix-shell # Use shells other than Bash in nix-shell & nix develop
      zsh # ZSH & non-oh-my-zsh-managed plugins
      zsh-history
      zsh-fzf-tab
      zsh-autocomplete
      zsh-you-should-use
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search
      oh-my-zsh
      nix-zsh-completions
      # cod # Tool for generating Bash/Fish/Zsh autocompletions based on `--help` output, broken
      jq # JSON CLI editor
      direnv # Auto-change environment options based on current directory
      orpie # CLI RPN calculator
      bitwise # CLI bit manipulation calculator
      strace # Trace program system calls, great for debugging
      difftastic # Good diffs for Git
      nixpkgs-fmt # Format Nix files
      wl-clipboard # Needed for zellilj option `copy_command = "wl-copy";` which is needed for clipboard to work on Wayland
    ];
  };

  xdg = {
    enable = true;
    userDirs.createDirectories = true;
    # These are *all* ephemeral here. If you don't want that, add them
    #  or subdirectories to the impermanence list above.
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Works around some issues with GTK programs on KDE Plasma desktops
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "breeze-gtk";
    };
  };
}
