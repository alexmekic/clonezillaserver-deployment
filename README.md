# Clonezilla iPXE Server Deployment Script
Easily create a Clonezilla iPXE server for restoring images over the network with minimum configuration required

## Features

- Script installs the following packages required to run the Clonezilla PXE server:
  - `sudo` for files editing requiring higher user privileges
  - `bash` to temporarily run `pxedeploy.sh` successfully to configure the server
  - `dnsmasq` for running a DHCP server to temporarily hand out IP address to any client computer booting over network to the PXE server and a TFTP server for handing out the correct boot files
  - `ipxe` for running a PXE server bootable for BIOS/EFI based client computers over network with the boot menu file
  - `samba410` for allowing `/pxe/images` to be accessed over a Windows computers to copy/backup restore images
  - `apache` for installing operating systems over network using HTTP protocol

- Creates new or import existing ZFS storage pool for storing operating system images
- `ClonezillaInstall` automatically downloads and unzips the latest stable version of Clonezilla to `/pxe/tftp/clonezilla` used for backing up and restoring operating system images to client computers
- Creates a boot menu file template called `boot.ipxe` containing backup imaging options for client computers to choose, and for storing new restore entires created via the PXE Management Application
- Configures `dnsmasq` to serve IP addresses with lease time of 1 hour and boot files `ipxe.pxe` for BIOS-based computers and `ipxe.efi` for EFI-based computers to be served
- Configures NFS and Apache as network sharing procotols for restoring images or installing an operating system over network
- Configures `/etc/rc.conf` file with IP addresses inputed by the user and all required services to be enabled and started on PXE server boot up

## System Requirements 

- Installation of FreeBSD 12.1 or greater
- Internet connection to download and install required packages

## Configuration Requirements upon using Script

- Minimum one static IP address for one NIC and used for DHCP server and Clonezilla
- IP address range for DHCP server
- Hostname of server
- Preferred admin account password, recommended to be as complex as possible

## Installation

- Login as root
- Type `pkg install -y git` to install git to download the Clonezilla deployment files
- Type `git clone git://github.com/kuroyoshi10/clonezillaserver-deployement` to download all the required files
- Type `chmod +x postinstall.sh` to allow the `postinstall.sh` to run
- Type `./postinstall.sh` to run the script file and follow the prompts

## Release History

- 1.0
  - Initial Release
- 1.1
  - Updated pxe_management compiled application in package with v1.2
  - Added command to set pxe zpool autorebuild to `on` for automatic ZFS rebuild
- 2.0
  - Updated pxe_management compiled application in package with v1.3
  - Revamped script for better user interactivity
    - Added Welcome message upon loading script
  - Added ability for user to make own admin account username
  - Added network card name for each network inteface detected for better identification upon IP configuration
  - Added feature for user to create or import ZFS storage pool
    - Added ability to display list of disks available and RAID options applicable
  - Added apache installation and configuration for operating system installs over network
  - Allow user to re-enter Samba password upon password mismatch
  - Added `os` subdirectory to Samba share configuration
- 2.1
  - Applied `chown` permissions on `images` directory to `nobody:wheel` to maintain permission functionality with Clonezilla Live
  - Redirected PXE Management Application to `pxe_management` subdirectory in zfs pool
  - Added boot entry for booting Clonezilla for manual control
  - Added ability to download latest Python management application in `ClonezillaInstall.py`
    - Redirected download link for Clonezilla Live to Sourceforge for faster download speed
    - Removed `pxe_management` application
  - Added option for single disk ZFS storage pool configuration