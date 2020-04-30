# Clonezilla iPXE Server Deployment Script
Easily create a Clonezilla iPXE server for restoring images over the network with minimum configuration required

## Features

- Script installs the following packages required to run the Clonezilla PXE server:
  - `sudo` for files editing requiring higher user privileges
  - `bash` to temporarily run `pxedeploy.sh` successfully to configure the server
  - `dnsmasq` for running a DHCP server to temporarily hand out IP address to any client computer booting over network to the PXE server and a TFTP server for handing out the correct boot files
  - `ipxe` for running a PXE server bootable for BIOS/EFI based client computers over network with the boot menu file
  - `samba410` for allowing `/pxe/images` to be accessed over a Windows computers to copy/backup restore images
  
- `ClonezillaInstall` automatically downloads and unzips the latest stable version of Clonezilla to `/pxe/tftp/clonezilla` used for backing up and restoring operating system images to client computers
- Creates a boot menu file template called `boot.ipxe` located under `/pxe/tftp` containing backup imaging options for client computers to choose, and for storing new restore entires created via the PXE Management Application
- Configures `dnsmasq` to serve IP addresses with lease time of 1 hour and boot files `ipxe.pxe` for BIOS-based computers and `ipxe.efi` for EFI-based computers to be served
- Configures NFS for `/pxe` containing restore images inside `/pxe/images` and installation of Clonezilla to be accessed over network
- Configures `/etc/rc.conf` file with IP addresses inputed by the user and all required services to be enabled and started on PXE server boot up
- Configures appropriate read/write permissions to `/pxe/images/`

## Need to know

- Script currently allows only one static NIC to be used for setting up `iPXE` and `dnsmasq`, rest of the NICs can be statically set or DHCP configured
- Permissions on `/pxe/images` are set to `753`, providing full access by the admin account but writeable only permissions for client computers booted off over network and backing up images via Clonezilla
  - Clonezilla uses another user account when Clonezilla is network booted

## System Requirements 

- Installation of FreeBSD 12.1 or greater with ZFS pool named `pxe`
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
- Type `./postinstall.sh` to run the script file and wait for all required packages to download and install
- Enter in all the required information for the iPXE Clonezilla server to operate normally

## Release History

- 1.0
  - Initial Release
- 1.1
  - Updated pxe_management compiled application in package with v1.2
  - Added command to set pxe zpool autorebuild to `on` for automatic ZFS rebuild