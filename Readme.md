# Installing NixOS with existing Windows with UEFI boot, root on tmpfs, home on tmpfs, everything else on encrypted ZFS datasets, and a flake-based config

Obviously this takes a lot of RAM. 12GiB for / and /home tmpfs in the defaults provided here. ECC RAM is *highly* recommended, the chance of error increases as RAM size increases.

This configuration example is for one machine (but should be easy to support more) and one user (with significantly more work to support more, due to a bug set to be solved by [this](https://github.com/NixOS/nixpkgs/pull/223932)). I expect most people reading this will not need multiple users, but may have multiple machines they want to configure.

If you're installing Windows, it's best if you manually partition your disk so you can have an EFI system partition larger than 100MiB. That allows for more NixOS boot generations to be stored. This config limits to 2 generations.

Disk partitions:  
/dev/disk/by-id/ID1 # Some disk name  
 ├─/dev/disk/by-id/ID1-part1 # EFI system partition, Windows makes this 100MiB by default. FAT32, make it bigger if you can.  
 ├─/dev/disk/by-id/ID1-part2 # MSR partition, Microsoft System Reserved  
 ├─/dev/disk/by-id/ID1-part3 # C: for Windows  
 ├─/dev/disk/by-id/ID1-part4 # ZFS root pool named "rpool"  
 ├─/dev/disk/by-id/ID1-part5 # Optional swap partition, not strictly necessary especially if you have tons of RAM  
 └─/dev/disk/by-id/ID1-part6 # Windows Recovery Partiton, usually around 650MiB, could be deleted  

Mount layout:  
 /		      tmpfs  
 ├─/boot          /dev/sda1   
 ├─/nix	          rpool/local/nix  
 ├─/home/persist  rpool/safe/home  
 └─/persist	      rpool/safe/persist  

Everything in `rpool/safe` is worth backing up. It's the state you've opted in to saving! Everything else can be re-generated if needed.

Note: This config is adapted from https://gist.github.com/byrongibson/b279469f0d2954cc59b3db59c511a199, with updates for current (23.05) NixOS options as needed, tmpfs home, flakes, etc.
Unlike that guide, this assumes you already have Windows installed and just shrank the `C:` partition to provide space for a ZFS partition, and have created an unformatted blank partition there.

## Useful commands  
`mount -l | grep sda`  
`findmnt | grep zfs`  
`lsblk`  
`ncdu -x /`   
`zpool list`  
`zfs list -o name,mounted,mountpoint`  
`zfs mount` (only usable with non-legacy datasets)  
`zfs unmount -a` (unmount everything, only usable with non-legacy datasets)  
`umount -R /mnt` (unmount everything in /mnt recursively, required for legacy zfs datasets)  
`zpool export $POOL` (disconnects the pool) NOTE: you MUST export the pool before reboot after running nixos-install.  
`zpool remove $POOL sda1` (removes the disk from your zpool)  
`zpool destroy $POOL` (this destroys the pool and it's gone and rather difficult to retrieve)  

Some ZFS properties cannot be changed after the pool and/or datasets are created.  Some discussion on this:  
https://www.reddit.com/r/zfs/comments/nsc235/what_are_all_the_properties_that_cant_be_modified/
`ashift` is one of these properties, but is easy to determine.  Use the following commands:
disk logical blocksize:  `$ sudo blockdev --getbsz /dev/sdX` (ashift)
disk physical blocksize: `$ sudo blockdev --getpbsz /dev/sdX` (not ashift but interesting)

You'll need to prefix essentially all of the following commands with `sudo`, so instead just enter a root shell with `sudo -i`. BE CAREFUL.

Pick your blank partition for ZFS `ls -l /dev/disk/by-id`, and save its path in a variable.

`ZFS=/dev/disk/by-id/YOUR_CHOICE_HERE`

Pick the EFI system partiton from `ls -l /dev/disk/by-uuid`, and save its path in a variable. By-id can work too.

`BOOT=/dev/disk/by-uuid/YOUR_CHOICE_HERE`

Create the ZFS pool, named "rpool" for this config:


-f force  
-m none (mountpoint), canmount=off.  ZFS datasets on this pool unmountable unless explicitly specified otherwise in 'zfs create'.  
Use blockdev --getbsz /dev/sdX to find correct ashift for your disk.  
acltype=posix, xattr=sa required  
atime=off and relatime=on for performance  
recordsize depends on usage, 16k for database server or similar, 1M for home media server with large files  
normalization=formD for max compatility  
secondarycache=none to disable L2ARC which is not needed  


More info on pool properties:  
https://nixos.wiki/wiki/NixOS_on_ZFS#Dataset_Properties  
https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/  

```
zpool create -f	-m none	-R /mnt \
    -o ashift=12                \
    -o listsnapshots=on         \
    -O acltype=posix            \
    -O compression=zstd         \
    -O encryption=on            \
    -O keylocation=prompt       \
    -O keyformat=passphrase     \
    -O canmount=off             \
    -O atime=off                \
    -O relatime=on              \
    -O recordsize=1M            \
    -O dnodesize=auto           \
    -O xattr=sa                 \
    -O normalization=formD      \
    -O secondarycachne=none     \
    rpool $ZFS
```

Make ZFS datasets for /nix, /persist, and /home/persist. Datasets under `/rpool/safe` should be backed up,
those under `/rpool/local` can be trivially re-created.

```
zfs create -p -v -o secondarycache=none -o mountpoint=legacy rpool/local/nix
zfs create -p -v -o secondarycache=none -o mountpoint=legacy rpool/safe/home
zfs create -p -v -o secondarycache=none -o mountpoint=legacy rpool/safe/persist
```

Create a reserved ZFS dataset. In case the pool runs out of space (even deletes take some space on copy-on-write filesystems) this can be shrunk or deleted to allow freeing space. Then this can be restored.

`zfs create -o refreservation=2G -o primarycache=none -o secondarycache=none -o mountpoint=none rpool/reserved`

Enable auto-snapshotting for the `safe` datasets:

`zfs set com.sun:auto-snapshot=true rpool/safe`

Make TMPFS, make directories and mount datasets:

```
mkdir -p /mnt
mount -t tmpfs tmpfs /mnt
mkdir -p /mnt/{nix,home,persist,boot}
```

Replace `USER` with your username in the following:

`mount -t tmpfs tmpfs /mnt/home/USER`

```
mkdir -p /mnt/home/persist
mount -t zfs rpool/local/nix /mnt/nix
mount -t zfs rpool/safe/home /mnt/home/persist
mount -t zfs rpool/safe/persist /mnt/persist
mount -t vfat "${BOOT:?} /mnt/boot
```

Make persistent subdirectories:

```
mkdir -p /mnt/persist/etc/{ssh,users,nixos,wireguard,NetworkManager/system-connections}
mkdir -p /mnt/persist/var/{log,lib/bluetooth}
```

Bind mount the /etc/nixos and /var/log directories:

```
mount -o bind /mnt/persist/etc/nixos /mnt/etc/nixos
mount -o bind /mnt/persist/var/log /mnt/var/log
```

If you want to use swap, don't forget to `mkswap` and `swapon` that partition.

Rename the host name in the example flake.nix (line 72), the folder name in nixos/hosts/ from `nix-win-dual-example` to your host name, and the `hostName` line in the `default.nix` in that folder on line 86.

Get a host ID and set it on line 87 of that file:

`head -c8 /etc/machine-id`

Set the boot.zfs.devNodes option on line 17 of that file to match your $ZFS partition.

Set the `/boot` device path to match your $BOOT partition on line 53.

Get what the generated hardware configuration would contain:

`nixos-generate-config --show-hardware-config`

Use those results to set the networking interfaces, drivers, and kernel modules in that file.

Configure the rest of the options as noted by `TODO:` in the sample files.

Copy *all* the edited sample files over to `/mnt/etc/nixos/`, so that `/mnt/etc/nixos/flake.nix` exists, etc. Since it's a bind-mount, it'll be persisted.

Make a password for your user, replacing PASSPHRASE and USERNAME below:

`mkpasswd -m yescrypt PASSPHRASE > /mnt/etc/users/USERNAME`

Run the install, with your host name instead of HOST_NAME:

`nixos-install --root /mnt --flake /mnt/etc/nixos#HOST_NAME`

Unmount `/mnt`:

`umount -R /mnt`

Export the ZFS pool (THIS IS MANDATORY, FAILURE TO EXPORT WILL PREVENT BOOT):

`zfs export rpool`

Reboot into your new system!
