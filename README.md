### EnterBSD: a FreeBSD livecd

These scripts create a FreeBSD livecd ISO, which can be used with or without a hard disk. 
It can be installed to hard disk or optionally, the hard disk may be used for data only.

The scripts can be installed on first reboot from the standard FreeBSD installation. They do not
depend on any extra downloaded software, except makeisofs, which we'll installed via a hack, 
(without using the pkg system.) After our first ISO is created from a clean FreeBSD install as 
above, the size will be around **230MB**. Only the unneeded boot/kernel modules are removed from 
the ISO, the rest is a complete FreeBSD install. The reason for the small size is that the 
filesystem is compressed via a module called geom_uzip. I found this article enlightening:
 
[https://wiki.freebsd.org/AndriyGapon/AvgLiveCD](https://wiki.freebsd.org/AndriyGapon/AvgLiveCD) 
Thank you Mr Gapon!

I'd like to call EnterBSD a self-replicating setup: When you have your system setup the way
that you like it, you can simply create an ISO again, which could then be run as a true livecd
with or without hard drive, but still containing all your data.


