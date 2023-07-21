# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
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
      # Segger J-link won't work without accepting the unfree license
      segger-jlink.acceptLicense = true;
    };
  };

  home = {
    username = "carl";
    homeDirectory = "/home/carl";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";

  home = {
    persistence."/home/persist/carl" = {
      directories = [
        ".ssh"
        "Downloads"
        "Documents"
        "Pictures"
        "code"
        "Music"
        "Videos"
        "Sync"
      ];
      files = [];
      allowOther = true;
    };

    packages = with pkgs; [
      htop
      #jetbrains.clion
      vscode-fhs
      vscode-extensions.bbenoist.nix
      vscode-extensions.ms-vscode.cpptools
      vscode-extensions.yzhang.markdown-all-in-one
      vscode-extensions.ms-python.python
      vscode-extensions.timonwong.shellcheck
      vscode-extensions.twxs.cmake
      vscode-extensions.ms-vscode.cmake-tools
      vscode-extensions.matklad.rust-analyzer
      vscode-extensions.mechatroner.rainbow-csv
      vscode-extensions.ms-azuretools.vscode-docker
      vscode-extensions.xaver.clang-format
      vscode-extensions.arrterian.nix-env-selector
      vscode-extensions.mkhl.direnv
      vscode-extensions.zxh404.vscode-proto3
      vscode-extensions.eamodio.gitlens
      vscode-extensions.ms-toolsai.jupyter
      vscode-extensions.ms-toolsai.vscode-jupyter-slideshow
      vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
      vscode-extensions.ms-toolsai.jupyter-renderers
      vscode-extensions.ms-toolsai.jupyter-keymap
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.ms-vscode.makefile-tools
      vscode-extensions.davidanson.vscode-markdownlint
      #google-chrome
      # bcompare # Beyond Compare, diff software, derivation broken
      dia
      #element-desktop
      inkscape
      libsForQt5.kdeconnect-kde
      libsForQt5.kdenlive
      libreoffice-qt
      lyx
      nanovna-saver
      steam # Includes Proton, allows running more Windows programs than WINE
      proton-caller
      python3
      bazel
      broot
      thefuck
      oil
      minicom
      fzf
      fishPlugins.foreign-env
      fishPlugins.fzf-fish
      b3sum
      black
      shellcheck
      tree
      binutils
      unzip
      fd
      ripgrep
      openssl
      obs-studio
      vlc
      nix-index
      any-nix-shell
      zsh
      zsh-z
      zsh-history
      zsh-fzf-tab
      zsh-autocomplete
      zsh-you-should-use
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search
      nix-zsh-completions
      # cod # Tool for generating Bash/Fish/Zsh autocompletions based on `--help` output, broken
      jq
      direnv
      gforth
      orpie # CLI RPN calculator
      bitwise # CLI bit manipulation calculator
      strace
      exa
      minicom
      difftastic
      rustup
      dhex
      lnav
      stlink
      usbutils
      saleae-logic-2
      nixpkgs-fmt
      gitkraken
      wl-clipboard # Needed for zellilj option `copy_command = "wl-copy";` which is needed for clipboard to work on Wayland
    ];

  # Raw configuration files.
  # Can't do this in pure mode.
  # KDE file tracking issue: https://github.com/nix-community/home-manager/issues/607
    file.".config/kxkbrc" = {
      text = ''
        [$Version]
        update_info=kxkb_variants.upd:split-variants

        [Layout]
        DisplayNames=
        LayoutList=us
        LayoutLoopCount=-1
        Model=pc86
        Options=terminate:ctrl_alt_bksp,compose:rctrl
        ResetOldOptions=true
        SwitchMode=Global
        Use=true
        VariantList=colemak
      '';
    };
  };


  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "breeze-gtk";
    };
  };

  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      # copy_on_select = false;
      copy_command = "wl-copy";
      default_shell = "fish";
    };
  };
}
