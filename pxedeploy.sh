#!/usr/local/bin/bash

function ip_validity {
        ip=${1:-$1}
        re='^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}'
        re+='0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))$'
        if [[ $ip =~ $re ]]; then
                return 0
        else
                return 1
        fi
}

function netmask_validity {
	echo $1 | grep -w -E -o '^(254|252|248|240|224|192|128)\.0\.0\.0|255\.(254|252|248|240|224|192|128|0)\.0\.0|255\.255\.(254|252|248|240|224|192|128|0)\.0|255\.255\.255\.(254|252|248|240|224|192|128|0)' > /dev/null
	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

function clonezilla_install {
	./ClonezillaInstall
}

function configure_hostname {
	read -e -p "Enter hostname of PXE server: " new_hostname
	sed -i '' "s/hostname=.*/hostname=\"$new_hostname\"/" /etc/rc.conf
	echo "Hostname updated to $new_hostname"
        local new_host=$new_hostname
        echo "$new_host"
}

function configure_admin_account {
	echo "Enter password for the admin account"
	pw useradd -n admin -m -s /bin/csh -G wheel -h 0 -L default
	echo -n "Setting admin account for sudo privileges..."
	sed -i '' "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /usr/local/etc/sudoers
	echo 'Defaults:admin timestamp_timeout=30' >> /usr/local/etc/sudoers
	echo "done"
}

function configure_ip {
	rm /usr/local/etc/dnsmasq.conf
	echo "NOTE: Only one network interface should have a static IP address"
        for int in $(ifconfig -l ether); do
		while true; do
			read -e -p "Configure $int? (DHCP|static|skip|exit): " int_prompt
			if [ $int_prompt == "DHCP" ]; then
				grep -q ifconfig_$int /etc/rc.conf
				if [ $? -eq 0 ]; then
					sed -i '' "s/ifconfig_$int=.*/ifconfig_$int=\"DHCP\"/" /etc/rc.conf
				else
					echo "ifconfig_$int=\"DHCP\"" >> /etc/rc.conf
				fi
				echo "Network interface $int set to DHCP"
				break
			elif [ $int_prompt == "static" ]; then
				while true; do
               				read -e -p "Enter IP Address for $int: " int_ip
					if ip_validity $int_ip; then
						break
					else
						echo "Invalid IP address"
					fi
				done
				while true; do
					read -e -p "Enter Netmask for $int: " netmask
					if netmask_validity $netmask; then
						grep -q ifconfig_$int /etc/rc.conf
						if [ $? -eq 0 ]; then
							sed -i '' "s/ifconfig_$int=.*/ifconfig_$int=\"inet $int_ip netmask $netmask\"/" /etc/rc.conf
						else
							echo "ifconfig_$int=\"inet $int_ip netmask $netmask\"" >> /etc/rc.conf
						fi
						echo "Network interface $int set to IP: $int_ip, Netmask: $netmask"
						break
					else
						echo "Invalid Netmask address"
					fi
				done
				while true; do
					read -e -p "Do you want to configure DHCP and setup PXE server for interface $int (y/n): " dhcp_prompt
					if [ $dhcp_prompt == 'y' ]; then
						if [[ -f /usr/local/etc/dnsmasq.conf ]]; then
							echo "DHCP and PXE configuration already configured from another interface"
						else
							configure_boot_ipxe $int_ip
							configure_dhcp $int $int_ip
							configure_nfs
							break
						fi
					elif [ $dhcp_prompt == 'n' ]; then
						break
					else
						echo "Invalid option"
					fi
				done
				break
			elif [ $int_prompt == "skip" ]; then
				break
			elif [ $int_prompt == "exit" ]; then
				return 0
			else
				echo "Invalid option"
			fi
		done
	done
}

function configure_dhcp {
	while true; do
		read -e -p "Enter starting IP address DHCP range for interface $1: " low_ip
		if ip_validity $low_ip; then
			break
		else
			echo "Invalid IP Address"
		fi
	done
	while true; do
		read -e -p "Enter ending IP address range: " high_ip
		if ip_validity $high_ip; then
			write_dhcp_file $1 $2 $low_ip $high_ip
			break
		else
			echo "Invalid IP Address"
		fi
	done
}

function write_dhcp_file {
	echo -n "Writing DHCP configuration..."
	echo "interface=$1
port=0
log-dhcp
listen-address=$2
no-hosts
dhcp-range=$3,$4,1h
dhcp-match=set:bios,60,PXEClient:Arch:00000
dhcp-boot=tag:bios,ipxe.pxe,$2
dhcp-match=set:efibc,60,PXEClient:Arch:00007
dhcp-boot=tag:efibc,ipxe.efi,$2
dhcp-match=set:efi64,60,PXEClient:Arch:00009
dhcp-boot=tag:efi64,ipxe.efi,$2
dhcp-match=set:iPXE,175
dhcp-boot=tag:iPXE,boot.ipxe
enable-tftp
tftp-root=/pxe/tftp" > /usr/local/etc/dnsmasq.conf
	echo 'dnsmasq_enable="YES"' >> /etc/rc.conf
	echo "done"
}

function configure_nfs {
	echo "/pxe -alldirs" > /etc/exports
	echo 'nfs_server_enable="YES"
mountd_enable="YES"
rpcbind_enable="YES"' >> /etc/rc.conf
}

function configure_samba {
	echo "Configuring Samba for Windows access..."
	echo "[global]
workgroup = WORKGROUP
server string = PXE Samba Server
netbios name = $1
wins support = Yes
security = user
passdb backend = tdbsam

[Images]
path = /pxe/images
valid users = admin
writable = yes
browsable = yes
read only = no
guest ok = no
public = no
create mask = 0666
directory mask = 0755" > /usr/local/etc/smb4.conf
	echo 'samba_server_enable="YES"' >> /etc/rc.conf
	echo "Type in the same password used for admin account to enable network sharing over Windows"
	pdbedit -a admin
	echo "done"
}

function configure_boot_ipxe {
	echo -n "Configuring iPXE..."
	cp /usr/local/share/ipxe/ipxe.pxe /pxe/tftp/
	cp /usr/local/share/ipxe/ipxe.efi-x86_64 /pxe/tftp/
	mv /pxe/tftp/ipxe.efi-x86_64 /pxe/tftp/ipxe.efi
	echo "#!ipxe

:start
menu PXE Server Boot Menu
item disk Backup Disk to Image
item partition Backup Partitions to Image
item shell Enter Shell
item exit Exit

choose --default shell option && goto \${option}

:disk
set cz_root nfs://$1/pxe/tftp/clonezilla/live
kernel \${cz_root}/vmlinuz initrd=initrd.img boot=live username=user \
union=overlay config components noswap edd=on nomodeset nodmraid \
locales=en_US.UTF-8 keyboard-layouts=NONE ocs_live_run=\"ocs-live-general\" \
ocs_live_extra_param=\"\" ocs_live_batch=no net.ifnames=0 nosplash noprompt \
ip=frommedia netboot=nfs nfsroot=$1:/pxe/tftp/clonezilla \
ocs_prerun1=\"mount -t nfs $1:/pxe/images /home/partimag -o \
noatime,nodiratime,\" oscprerun2=\"sleep 10\" ocs_live_run=\"/usr/sbin/ocs-sr \
-q2 -j2 -nogui -z1p -i 1000000 -fsck-y -senc -p reboot savedisk ask_user \
ask_user\"
initrd \${cz_root}/initrd.img
imgstat
boot
:partition
set cz_root nfs://$1/pxe/tftp/clonezilla/live
kernel \${cz_root}/vmlinuz initrd=initrd.img boot=live username=user \
union=overlay config components noswap edd=on nomodeset nodmraid \
locales=en_US.UTF-8 keyboard-layouts=NONE ocs_live_run=\"ocs-live-general\" \
ocs_live_extra_param=\"\" ocs_live_batch=no net.ifnames=0 nosplash noprompt \
ip=frommedia netboot=nfs nfsroot=$1:/pxe/tftp/clonezilla \
ocs_prerun1=\"mount -t nfs $1:/pxe/images /home/partimag -o \
noatime,nodiratime,\" oscprerun2=\"sleep 10\" ocs_live_run=\"/usr/sbin/ocs-sr \
-q2 -j2 -nogui -z1p -i 1000000 -fsck-y -senc -p reboot saveparts ask_user \
ask_user\"
initrd \${cz_root}/initrd.img
imgstat
boot
:shell
shell
:exit
exit" > /pxe/tftp/boot.ipxe
	echo "done"
	echo "Default boot menu file created"
}

function create_pxe_directories {
	echo -n "Creating required PXE folders..."
	mkdir /pxe/images
	mkdir /pxe/tftp
	mkdir /pxe/tftp/clonezilla
	chmod -R 777 /pxe/images
	echo "done"
}

function copy_management {
	echo -n "Copying PXE Management Script and configuring for startup at login..."
	chmod +x pxe_management
	cp pxe_management /usr/home/admin
	echo "Loading PXE Management Script..." >> /usr/home/admin/.login
	echo "./pxe_management" >> /usr/home/admin/.login
	chown -R admin:admin /usr/home/admin/.login
	chown -R admin:admin /usr/home/admin/pxe_management
	echo "done"
}

new_host="$(configure_hostname)"
configure_admin_account
configure_samba $new_host
create_pxe_directories
configure_ip
clonezilla_install
chown -R admin:admin /pxe/images
chmod 753 /pxe/images
chown -R admin:admin /pxe/tftp
copy_management
echo "Rebooting..."
reboot
