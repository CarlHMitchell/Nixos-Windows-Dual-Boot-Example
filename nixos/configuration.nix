# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {

  #############################################################################
  # Nix
  #############################################################################

  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };

    # NOTE: Nix garbage collection won't find roots in `/nix/var/nix/gcroots/auto/`
    #  There's a good chance you want to keep some of those, but others may be stray.
    #  See https://nixos.wiki/wiki/Storage_optimization
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Auto collect garbage to free up to 1GiB whenever there's less than 100MiB left
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  system = {
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.05"; # Did you read the comment?

    autoUpgrade = {
      enable = true;
      flake = "/persist/etc/nixos/flake.nix";
      flags = [ "--update-input" "nixpkgs" ];
      allowReboot = true; # Reboot if the new generation would require it
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MEASUREMENT = "en_DK.UTF-8"; # TODO: Remove if you don't want SI units even in US English.
      LC_TIME = "en_CA.UTF-8"; # TODO: Remove if you don't want ISO-8601/RFC-3339 date strings. 
    };
  };
  console = {
    font = "Lat2-Terminus16";
    # The console keyMap sets the keyboard layout used to enter the filesystem passphrase!
    keyMap = "us"; # TODO: Pick your keyboard layout for consoles.
    # keyMap = "colemak";
  };

  # See the "TZ identifier columen at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "Etc/UTC"; # TODO: Pick your time zone.

  #############################################################################
  # Boot
  #############################################################################

  # This could go in per-host config, but if all hosts use ZFS it'd just get
  #  duplicated a lot.

  # Use EFI boot loader with Systemd-boot
  # https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning-UEFI
  boot = {
    supportedFilesystems = [ "vfat" "zfs" ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 2; # TODO: You can set this higher if you have a larger /boot than the Windows default
      };
      efi = {
        canTouchEfiVariables = true;
        #efiSysMountPoint = "/boot/efi";  # using the default /boot for this config
      };
    };
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    initrd = {
      kernelModules = [ "zfs" ];
      postDeviceCommands = ''
        zpool import -l rpool
      '';
    };
  };

  #############################################################################
  # ZFS
  #############################################################################

  boot.zfs = {
    requestEncryptionCredentials = true; # enable if using ZFS encryption, ZFS will prompt for password during boot
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  #############################################################################
  # Networking
  #############################################################################

  networking = {
    networkmanager.enable = true;
  };

  #############################################################################
  # Security
  #############################################################################

  security.sudo.wheelNeedsPassword = false; # TODO: If you want to type a password for sudo, set this to true

  #############################################################################
  # Persisted Artifacts
  #############################################################################

  # Erase Your Darlings & Tmpfs as Root & Home:
  # config/secrets/etc to be persisted across tmpfs reboots and rebuilds. Sets up
  # soft-links from /persist/<loc on root> to their expected location on /<loc on root>
  # Further reading:
  # https://github.com/barrucadu/nixfiles/blob/master/README.markdown
  # https://github.com/barrucadu/nixfiles/blob/master/hosts/nyarlathotep/configuration.nix
  # https://grahamc.com/blog/erase-your-darlings
  # https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
  # https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/
  # https://github.com/nix-community/impermanence


  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/chrony" # if using Chrony for NTP
      "/var/lib/bluetooth"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/wireguard/wg0"
    ];
  };

  ################################################################################
  # GnuPG, SSH, and Wireguard
  ################################################################################

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings  = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys =
      [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
  };

  # Enable GnuPG Agent
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };

  # Wireguard: requires /persist/etc/wireguard/, handled by impermanence module
  networking.wireguard.interfaces.wg0 = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/etc/wireguard/wg0";
  };

  ################################################################################
  # Window Managers & Desktop Environment
  ################################################################################

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Enable the Plasma 5 Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    # Configure keymap in X11
    layout = "us";
    # xkbVariant = "colemak"; # If you want a "variant" layout, put it here
    xkbOptions = "caps:escape"; # map caps to escape.
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  ################################################################################
  # Print
  ################################################################################

  # Enable CUPS to print documents.
  services.printing.enable = true;

  ################################################################################
  # Sound
  ################################################################################

  # Enable sound, with PipeWire & PulseAudio.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  ################################################################################
  # Users
  ################################################################################

  # When using a password file via users.users.<name>.passwordFile, put the
  # passwordFile in the specified location *before* rebooting, or you will be
  # locked out of the system.  To create this file, make a single file with only
  # a password hash in it, by running `mkpasswd` and saving the output.
  # Or you can copy-paste your password hash from `/etc/shadow` if you first built
  # the system with `password=`, `hashedPassword=`, initialPassword-, or
  # initialHashedPassword=. `sudo cat /etc/shadow` will show all hashed user passwords.
  # More info:  https://search.nixos.org/options?channel=21.05&show=users.users.%3Cname%3E.passwordFile&query=users.users.%3Cname%3E.passwordFile

  users = {
    mutableUsers = false;
    defaultUserShell = "/var/run/current-system/sw/bin/zsh"; # TODO: Pick a default user shell
    users = {
      root = {
        # disable root login here, and also when installing nix by running `nixos-install --no-root-passwd`
        # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/3
        hashedPassword = "!";  # disable root logins, nothing hashes to !
      };
      USER = { # TODO: Set your username
        isNormalUser = true;
        description = "USER DESCRIPTION"; # TODO: Set your user description 
        home = "/home/USER"; # TODO: Set to your username. MUST match the `fileSystems."/home/USER" =` value.
        createHome = true; # Does nothing, due to a bug. https://github.com/NixOS/nixpkgs/pull/223932 should resolve it. Harmless here.
        passwordFile = "/persist/etc/users/USER"; # TODO: Set your username. Be sure to create this *before* rebooting during first install!
        extraGroups = [ "wheel" "networkmanager" "audio" "dialout" "dumpcap" ]; # TODO: add any extra groups, e.g. "docker" for Docker or "dumpcap" for Wireshark
        #openssh.authorizedKeys.keys = [ "${AUTHORIZED_SSH_KEY}" ]; # TODO: Add keys that can log into *this* user account from _other_ computers.
      };
    };
  };

  ################################################################################
  # Applications
  ################################################################################

  # List packages installed in system profile. To search, run:
  # $ nix search <packagename>
  # Or better yet use search.nixos.org
  # TODO: Edit this list to your liking
  environment.systemPackages = with pkgs; [
    # Useful mostly-minimal package set for a first install:
    nix-index # Nix package lookup
    efibootmgr # EFI management
    parted gparted gptfdisk # Disk partitioning
    pciutils uutils-coreutils wget rsync # Commonly-needed utilities
    openssh ssh-copy-id ssh-import-id fail2ban sshguard # SSH & helpers
    git git-extras git-lfs # Git version control
    zsh oh-my-zsh # Z Shell
    firefox irssi # Browser & IRC
    screen tmux zellij # Terminal multiplexers
    vim nano emacs # Commonly-used text editors
    htop ncdu qdirstat # System usage monitoring
    keepassxc libsecret # Password management
    starship # Pretty terminal prompt
    plasma-pa # Pulseaudio control in KDE Plasma
    # st-link # Used as an example for a custom udev rule below.
  ];

  ################################################################################
  # Program Config
  ################################################################################

  # TODO: Customize to your liking. This is for ALL users.
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "colorize"
        "command-not-found"
        "emacs"
        "git"
        "git-extras"
        "history"
        "man"
        "rsync"
        "safe-paste"
        "scd"
        "screen"
        "systemd"
        "tmux"
        "urltools"
        "vi-mode"
        "z"
        "zsh-interactive-cd"
      ];
    };
  };

  programs.fish.enable = true;

  programs.kdeconnect.enable = true;
  
  programs.fuse.userAllowOther = true;

  programs.dconf.enable = true; # Required for some GNOME programs to work.

  ################################################################################
  # Other Services Config
  ################################################################################

  services.chrony.enable = true;

  # TODO: Customize these sizes for how much journal output to store
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemKeepFree=1G
  '';

  services.syncthing = {
    enable = true;
    dataDir = "/home/persist/USER/Sync"; # TODO: Set to your user
    openDefaultPorts = true;
    configDir = "/home/persist/USER/.config/syncthing"; # TODO: Set to your user
    user = "USER"; # TODO: Set to your user
    group = "users";
    guiAddress = "127.0.0.1:8384";
  };

  # Example of adding a udev rule
  # services.udev.packages = [ pkgs.stlink ];
  # services.udev.extraRules = ''
  #   ACTION=="add", ATTRS{idVendor}=="0a01", ATTRS{idProduct}=="0005", ATTR{power/wakeup}="enabled"
  # '';
}
