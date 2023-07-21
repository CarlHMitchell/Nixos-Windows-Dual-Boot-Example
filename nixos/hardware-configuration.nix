{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
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

  fileSystems."/home" =
    { device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
    };

  fileSystems."/home/persist" =
    { device = "rpool/safe/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/083E-15B7";
      fsType = "vfat";
      neededForBoot = true;
    };

  fileSystems."/etc/nixos" =
    { device = "/persist/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.hostId = "dab9366c";
  boot.zfs.devNodes = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNX0MA39320-part5";
}
