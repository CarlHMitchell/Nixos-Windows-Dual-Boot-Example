# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {

  ##############################################################################
  # Nix
  ##############################################################################

  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
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

    gc.automatic = true;
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
      allowReboot = true;
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_TIME = "en_CA.UTF-8";
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "colemak";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  time.timeZone = "America/New_York";
  services.chrony.enable = true;


  ##############################################################################
  # Boot
  ##############################################################################

  # Probably better in per-host config, but if all hosts use ZFS it'd just get
  #  duplicated a lot.
  # Use EFI boot loader with Systemd-boot
  # https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning-UEFI
  boot = {
    supportedFilesystems = [ "vfat" "zfs" ];
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;  # must be disabled if efiInstallAsRemovable=true
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

  ################################################################################
  # ZFS
  ################################################################################

  # Set the disk’s scheduler to none. ZFS takes this step automatically
  # if it controls the entire disk, but since it doesn't control the /boot
  # partition we must set this explicitly.
  # source: https://grahamc.com/blog/nixos-on-zfs
  boot.kernelParams = [ "elevator=none" ];

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
    hostName = "nix-win-dual-test";  # Any arbitrary hostname.
    networkmanager.enable = true;
  };

  #############################################################################
  # Security
  #############################################################################

  security.sudo.wheelNeedsPassword = false;

  ################################################################################
  # Persisted Artifacts
  ################################################################################

  # Erase Your Darlings & Tmpfs as Root & Home:
  # config/secrets/etc to be persisted across tmpfs reboots and rebuilds.  setup
  # soft-links from /persist/<loc on root> to their expected location on /<loc on root>
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

  #2. Wireguard:  requires /persist/etc/wireguard/
  networking.wireguard.interfaces.wg0 = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/persist/etc/wireguard/wg0";
  };

  #3. Bluetooth: requires /persist/var/lib/bluetooth
  #4. ACME certificates: requires /persist/var/lib/acme
  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];

  ################################################################################
  # GnuPG & SSH
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
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
  };

  # Enable GnuPG Agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  ################################################################################
  # Drivers
  ################################################################################

  hardware.opengl = {
    driSupport = true;  # install and enable Vulkan: https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel
    #extraPackages = [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl ];  # only if using Intel graphics
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
    xkbVariant = "colemak";
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

  # Enable sound.
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
  # a password hash in it, compatible with `chpasswd -e`.  Or you can copy-paste
  # your password hash from `/etc/shadow` if you first built the system with
  # `password=`, `hashedPassword=`, initialPassword-, or initialHashedPassword=.
  # `sudo cat /etc/shadow` will show all hashed user passwords.
  # More info:  https://search.nixos.org/options?channel=21.05&show=users.users.%3Cname%3E.passwordFile&query=users.users.%3Cname%3E.passwordFile

  users = {
    mutableUsers = false;
    defaultUserShell = "/var/run/current-system/sw/bin/zsh";
    users = {
      root = {
        # disable root login here, and also when installing nix by running nixos-install --no-root-passwd
        # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/3
        hashedPassword = "!";  # disable root logins, nothing hashes to !
      };
      test = {
        isNormalUser = true;
        description = "Non-sudo account for testing new config options that could break login.  If need sudo for testing, add 'wheel' to extraGroups and rebuild.";
        initialPassword = "password";
        #passwordFile = "/persist/etc/users/test";
        extraGroups = [ "networkmanager" ];
        #openssh.authorizedKeys.keys = [ "${AUTHORIZED_SSH_KEY}" ];
      };
      carl = {
        isNormalUser = true;
        description = "Carl";
        passwordFile = "/persist/etc/users/carl";
        extraGroups = [ "wheel" "networkmanager" "audio" "dialout" "docker" "dumpcap" ];
        #openssh.authorizedKeys.keys = [ "${AUTHORIZED_SSH_KEY}" ];
      };
    };
  };

  ################################################################################
  # Applications
  ################################################################################

  # List packages installed in system profile. To search, run:
  # $ nix search <packagename>
  environment.systemPackages = with pkgs; [

    # system core (useful for a minimal first install)
    nix-index
    efibootmgr
    parted gparted gptfdisk
    pciutils uutils-coreutils wget
    openssh ssh-copy-id ssh-import-id fail2ban sshguard
    git git-extras git-lfs
    zsh oh-my-zsh
    firefox irssi
    screen tmux
    vim nano
    htop ncdu
    qdirstat
    ark
    keepassxc libsecret
    qdirstat
    starship
    plasma-pa
  ];

  ################################################################################
  # Program Config
  ################################################################################

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "colored-man-pages" "colorize" "command-not-found" "emacs" "git" "git-extras" "history" "man" "rsync" "safe-paste" "scd" "screen" "systemd" "tmux" "urltools" "vi-mode" "z" "zsh-interactive-cd" ];
      theme = "juanghurtado";
      #theme = "jonathan";
      # themes displaying commit hash: jonathan juanghurtado peepcode simonoff smt sunrise sunaku theunraveler
      # cool themes: linuxonly agnoster blinks crcandy crunch essembeh flazz frisk gozilla itchy gallois eastwood dst clean bureau bira avit nanotech nicoulaj rkj-repos ys darkblood fox
    };
  };

  programs.kdeconnect.enable = true;
  
  programs.fuse.userAllowOther = true;

  ################################################################################
  # Other Services Config
  ################################################################################

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemKeepFree=1G
  '';

  services.syncthing = {
    enable = true;
    dataDir = "/home/persist/carl/Sync";
    openDefaultPorts = true;
    configDir = "/home/persist/carl/.config/syncthing";
    user = "carl";
    group = "users";
    guiAddress = "127.0.0.1:8384";
  };

  services.udev.packages = [ pkgs.stlink ];
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="0a01", ATTRS{idProduct}=="0005", ATTR{power/wakeup}="enabled"
  '';
}
