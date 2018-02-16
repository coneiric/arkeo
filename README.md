# Arkeo

Arkeo (Esperanto): ark, ark of the covenant, box containing divine valuables ;)

This is a project intended to make it easy to use, develop, and test Kovri & Monero.

## Creating a Development & Testnet ISO with Archiso

Arkeo ISO is built on Arch Linux and the Archiso toolset.

### Prerequisites
- Arch Linux system
- archiso

### Build instructions

Detailed instructions for building and customizing the archiso profile is available on the [Arch
wiki](https://wiki.archlinux.org/index.php/Archiso)

Arkeo is based on the `releng` archiso profile, with customizations to install Kovri, Monero, and their dependencies.

To build the ISO:
```
$ cd /path/to/arkeo
# ./build.sh [-N your_iso_name] [-v]
```

After running the above command, your ISO will be in `out/your_iso_name.iso`.

### Rebuilding instructions

If you built the ISO, and want to make further changes (installing packages, configuration, etc), then you can rebuild
the ISO.

You will need to remove pacman's lock files, and run `build.sh` again:
```
$ cd /path/to/kovri/contrib/archiso
# rm -v work/build_*
# ./build.sh
```

### Preparing the live media

There are different setups required for a development or testnet LiveUSB.

#### Development LiveUSB 

The development LiveUSB is the easiest to prepare. 

##### WARNING: dd can overwrite your system drive, ensure you write to the proper drive

Insert a USB and write the ISO:
```
$ cd /path/to/arkeo
# dd if=out/your_iso_name.iso of=/dev/sdX bs=1M
```

In the above command, `/dev/sdX` is the path to your USB, where `X` is the proper drive letter.

#### Testnet LiveUSB

Currently, the Kovri testnet relies on Docker, which will not run from a LiveUSB.

Docker does not support running on top of an OverlayFS base filesystem.
If you wish to build the Docker-based Kovri testnet, please [install Arkeo to
disk](https://wiki.archlinux.org/index.php/Archiso#Installation_without_Internet_access).

Work is in progress to build a Kovri testnet without Docker.

The final preparation of the testnet LiveUSB is the same as the development LiveUSB.

##### WARNING: dd can overwrite your system drive, ensure you write to the proper drive

Insert a USB and write the ISO:
```
$ cd /path/to/arkeo
# dd if=out/your_iso_name.iso of=/dev/sdX bs=1M
```

In the above command, `/dev/sdX` is the path to your USB, where `X` is the proper drive letter.
