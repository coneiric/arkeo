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

While building the ISO, a prompt will ask to build the Kovri testnet.
By default, the testnet will be built, so just press enter.

If you wish to customize testnet environment variables, edit `build_kovri_testnet()` in
`path/to/arkeo/airootfs/root/customize_airootfs.sh`.

You may be prompted to destroy an existing testnet on your first build, doing so will not affect your testnet setup.

If you wish to keep an existing testnet from a previous build, enter "n" when prompted to destroy an existing testnet.

The final preparation of the testnet LiveUSB is the same as the development LiveUSB.

##### WARNING: dd can overwrite your system drive, ensure you write to the proper drive

Insert a USB and write the ISO:
```
$ cd /path/to/arkeo
# dd if=out/your_iso_name.iso of=/dev/sdX bs=1M
```

In the above command, `/dev/sdX` is the path to your USB, where `X` is the proper drive letter.
