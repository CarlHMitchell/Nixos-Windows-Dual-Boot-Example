{ inputs, config, lib, pkgs, modulesPath, ... }: {
  # Host-specific config, mostly what usually goes in `hardware-configuration.nix`.
  # Each host machine can have its own folder and settings here.
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  #############################################################################
  # Boot
  #############################################################################
  # TODO: Replace these with the results of your hardware scan
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    zfs.devNodes = "/dev/disk/by-id/ZFS_PARTITION"; # TODO: replace ZFS_PARTITION with your ZFS partition ID, from `ls -l /dev/disk/by-id/`
  };

  fileSystems."/" =
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ]; # TODO: Set the size based on how much space you want ephemeral data to take.
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/persist" =
    { device = "rpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  # Until https://github.com/NixOS/nixpkgs/pull/223932 is merged and in the release you're using,
  #  home dirs have to exist, users.users.<username>.createHome won't work on tmpfs
  #  Once that fix is in, this can be changed to `fileSystems."/home" =`
  fileSystems."/home/USER" = # TODO: Set your username here. Must match the users.users value.
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=12G" "mode=700" "uid=1000" "gid=100" "user" ]; # TODO: Set the size based on how much space you want ephemeral data to take.
    };

  fileSystems."/home/persist" =
    { device = "rpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/UUID"; # TODO: Replace with your /boot disk UUID, from `ls -l /dev/disk/by-uuid`
      fsType = "vfat";
      neededForBoot = true;
    };

  fileSystems."/etc/nixos" =
    { device = "/persist/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/persist" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/persist" ];
      neededForBoot = true;
    };

  swapDevices = [ ]; # TODO: If using swap, put in the partition's path in /dev/disk/by-id/ or other /dev/disk/by-* folder.

  #############################################################################
  # Networking
  #############################################################################

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  networking = {
    interfaces.enp0s31f6.useDHCP = lib.mkDefault true; # TODO: Your hardware will likely have different adapters here
    interfaces.wlp0s20f3.useDHCP = lib.mkDefault true; # TODO: Your hardware will likely have different adapters here
    hostName = "nix-win-dual-example"; # TODO: Change this to what you want the host named. Best to match the flake & folder.
    hostId = "HOSTID"; # TODO: replace HOSTID with your host ID, a persistent random value
  };

  ################################################################################
  # Drivers
  ################################################################################

  hardware.opengl = {
    driSupport = true;  # install and enable Vulkan: https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel
    #extraPackages = [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl ];  # only if using Intel graphics
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; # Only tested on x86_64
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave"; # good for a laptop or not wasting energy
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; # TODO: This will differ for AMD users
}
