debian 7 software-raid setup
==============

###### after a fresh debian 7 install...

#### first make sure all the necessary disk programs are installed

    sudo apt-get install mdadm smartmontools

if mdadm brings up a configuration screen prompting you for arrays to start at boot then enter `none`. and answer `yes` to the question `Do you want to start MD arrays automatically?`

#### now manually make sure all disks are in good shape

list the disks:

    sudo fdisk -l

this should return something like `disk /dev/sda`.

now run a short test on this disk using [smart](http://www.linuxjournal.com/magazine/monitoring-hard-disks-smart) (there is no need to unmount the disk first):

	sudo smartctl --test=short /dev/sda

and after a minute or so, check the status of this disk:

    sudo smartctl -a /dev/sda

look for the following heading:

    SMART Self-test log structure

this will tell you the status of the short test. you want to see a status of `Completed without error` here. also look at the following line:

    Reallocated_Sector_Ct

if the raw value is below the threshold then all is well. if the value is equal to or above the threshold then the disk needs replacing immediately.

#### set up smartd to automatically monitor all disks

open file `/etc/default/smartmontools` and uncomment the following line:

    #start_smartd=yes

then open the `/etc/smartd.conf` file. include a line like so for each disk:
https://help.ubuntu.com/community/Smartmontools

    /dev/sda -S on -o on -a -s (O/../.././23|L/../../5/03) -m root

this command contains the following settings:

 - `-S on` - enable automatic attribute save
 - `-o on` - enable automatic offline testing
 - `-a` - monitor all smart features of the disk. checks the health status (-H), failures (-f), track changes in attributes (-t)
 - `-s (O/../.././23|L/../../5/03)` - `O/../.././23` means schedule an offline immediate test every day at 11pm. `L/../../5/03` means schedule a long self-test every friday at 3am.
 - `-m root` - send an email to the root user when the specified criteria is met

#### create a raid1 device (using 2 disks)

#### grow the raid1 to a raid6 (now using 4 disks)

raid6 can handle 2 disks dying simultaneously, but raid5 can only handle 1 (cautionary tale: http://serverfault.com/q/614523/132992)

#### raid email notification setup

#### simulating a disk failure

#### deleting the raid
