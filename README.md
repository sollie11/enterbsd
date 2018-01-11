# enterbsd
FreeBSD livecd
Boot FreeBSD-11.1-64.iso
Install
Keyboard
Hostname enter.local.lan
Distribution deselect ports
Partitioning Auto UFS Entire Disk GPT Finish Commit
Root password toor toor
Network em0 IPV4=yes DHCP=yes IPV6=no
Resolver search=empty IPV4#1=8.8.8.8, #2=empty
Timezone America/Brazil/Brazil southeast -2=yes set time
System switch off dumpdev
Hardening switch on all but top 2
Add users yes user 'Logged In' 5000 'wheel operator video' Empty 
password=yes, yes no
Exit, wait a while sometimes... No Reboot, wait, kill vm, setup to boot hd, do not remove iso

Boot from hd
login root
ee /etc/ssh/sshd-config
### 4 pgdn
PermitRootLogin yes
###

service sshd restart
ifconfig



ssh to machine
################################3

freebsd-update fetch
###press qq a few times (44 patches 20171230)
freebsd-update install

cd /root
fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/cdrtools-3.01.txz
fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/gettext-runtime-0.19.8.1_1.txz
fetch http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/indexinfo-0.2.6.txz
unxz *.txz
mkdir usr
cd usr
tar -pxvf ../cdrtools* 
tar -pxvf ../gettext*
tar -pxvf ../index*
cd usr/local
tar -pcf - . | ( cd / && tar -pxf - )
cd ../../../
rm -rf usr
rm *.tar

mkdir /mnt/cdrom
mount -t cd9660 /dev/cd0 /mnt/cdrom
cd /
touch 00prep
chmod +x 00prep


ee 00prep
### paste .shell file contents


./00prep

########################
