### EnterBSD: a FreeBSD livecd

These scripts create a FreeBSD livecd ISO, which can be used with or without a hard disk. 
It can be installed to hard disk or optionally, the hard disk may be used for data only.

The scripts can be installed on first reboot from the standard FreeBSD installation. They do not
depend on any extra downloaded software, except makeisofs, which will be installed via a hack, 
(without using the pkg system.) After our first ISO is created from a clean FreeBSD install as 
above, the size will be around **230MB**. Only the unneeded boot/kernel modules are removed from 
the ISO, the rest is a complete FreeBSD install. The reason for the small size is that the 
filesystem is compressed via a module called geom_uzip. I found this article enlightening:
 
[https://wiki.freebsd.org/AndriyGapon/AvgLiveCD](https://wiki.freebsd.org/AndriyGapon/AvgLiveCD) 
Thank you Mr Gapon! I am using this exact technique.

I'd like to call EnterBSD a self-replicating setup: When you have your system setup the way
that you like it, you can simply create an ISO again, which could then be run as a true livecd
with or without hard drive, but still containing all your data.

**HOW**
1. We start by installing FreeBSD-11.1-RELEASE (I use VirtualBox). I have some guidelines in 
instructions.txt to show how I setup FreeBSD, but your own options really won't influence the process.

2. Reboot the newly installed system from HD, remember to keep the CDROM device attached.

3. Modify sshd to allow root access. (We can change this back later.)
login: root

`ee /etc/ssh/sshd-config`

*Find this line and change to yes:*

`PermitRootLogin yes`

*Esc-a-a to save*

4. Restart sshd and ssh from your desktop machine.

`service sshd restart`

`ifconfig`

5. Run freebsd-update

`freebsd-update fetch`

*Press qq a few times until prompt appears*

`freebsd-update install`


6. Copy and paste a few shell commands to install mkisofs, the utility we need to create the ISOs. We
do not want to install via pkg, because pkg itself downloads and consumes around 50MB, which adds to 
the size of the ISO. Please download the latest versions of the three files, these versions were valid 
on 2018-01-12. 

`cd /root`

`fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/cdrtools-3.01.txz`

`fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/gettext-runtime-0.19.8.1_1.txz`

`fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/indexinfo-0.2.6.txz`

`unxz *.txz`

`mkdir usr`

`cd usr`

`tar -pxvf ../cdrtools*` 

`tar -pxvf ../gettext*`

`tar -pxvf ../index*`

`cd usr/local`

`tar -pcf - . | ( cd / && tar -pxf - )`

`cd ../../../`

`rm -rf usr`

`rm *.tar`

`mkdir /mnt/cdrom`

`mount -t cd9660 /dev/cd0 /mnt/cdrom`

`cd /`

`touch 00prep`

`chmod +x 00prep`


7. Copy and paste the contents of script.sh

`ee 00prep`

*Paste the contents, Esc-a-a to save*

8. Run the script. This creates all the necessary files. We make a symlink to the real directory too.

`./00prep`

`ln -s /data/disk/mkiso /1`

`cd /1`

`ls -l`

9. The files starting with '0' should now be run in succession:

`./00clean && ./01create && ./02clone && ./04etc`

*The next one could take some time*

`./06mksys`

*Finally, create the ISO, enter a suffix for your ISO filename.

`./07mkcd FIRST`


*The ISO file will is located in the same directory*

`ls -l`


Copy the file to your VirtualBox ISO directory and setup a machine to boot from it!



