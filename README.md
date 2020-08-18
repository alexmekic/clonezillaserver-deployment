# Clonezilla PXE Server Deployment Script
Easily create a Clonezilla PXE server for restoring images over the network with minimum configuration required

## Features

- Installs required packages for Clonezilla PXE server to run
- Configures the following upon deployement:
  - DHCP for leasing IP address to client computers booting over network using
  - NFS for client computers to access restore images via Clonezilla Live, Linux or FreeBSD
  - Samba for access to images from Windows computers
  - Apache for client computers to install operating systems over network
- Creates new or import existing ZFS storage pool for storing operating system images
- Allows user to choose name for admin username account, password and ZFS storage pool for storing operating system images
- Automatically downloads and installs the latest version of Clonezilla Live
- Copies iPXE files necessary booting client computers over network via BIOS or EFI
- Creates a template boot entry file for client computers booting over network with option to make a disk or partition backup, and boot directly to Clonezilla Live for manual backup and restore

## System Requirements 

- Installation of FreeBSD 12.1 or greater
- Minimum 4GB of RAM recommended
- Minimum 2 hard disk or solid state drives
- Desktop or server with minimum two NIC's installed
  - One NIC required dedicated for DHCP and PXE
- Internet connection to download and install required packages

## Installation (to be updated)

- Login as root
- Type `pkg install -y curl` to install curl to download the Clonezilla deployment release files
- Type `curl -L -O http://github.com/kuroyoshi10/clonezillaserver-deployement/releases/download/2.1/PXEDeploy2.1.zip` to download all the required files
- Unzip it with `unzip PXEDeploy2.1.zip`
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
