debian wheezy os setup
==============

###### after a fresh debian 7 install...

#### first test if sudo is installed and enabled for your user (bob):

    sudo echo hi

if you see

    -bash: sudo: command not found

then `sudo` is not installed. login as root and install it like so:

    su
    apt-get install sudo
    exit

then try again:

    sudo echo hi

if you see the following message, then sudo is not enabled for your user:

    bob is not in the sudoers file. This incident will be reported.

so add your user to the sudoers file:

    su -
    visudo

add line to enable sudo for user `bob`

    bob    ALL=(ALL:ALL) ALL

#### very important for system recovery down the track

check to see what drives are mounted on your install:

    df -h

and copy 3 files of approx 500mb each into the root filesystem. this provides a buffer if your drive fills up later on - you can delete one of the files which may give you time to fix the problem.

#### now bring all debian packages up to date

run a package-list update to bring in details any new packages that the installer cd did not know about:

    sudo apt-get update

upgrade any of the packages which were out of date:

    sudo apt-get dist-upgrade

check if there are any packages which have not been properly removed:

    dpkg -l | grep "^r"

upon initial os install, package `user-setup` will probably be found. remove it:

    sudo dpkg --purge user-setup

#### if on a laptop and the wireless network card is not working:

    lspci -nn | grep -i network

this should give the name of the device whose firmware needs to be installed - google 'debian install <device name> firmware'

###### example for the broadcomm bcm4311 wireless network device (https://wiki.debian.org/bcm43xx):

first edit the `/etc/apt/sources.list` file. replace line

    deb http://ftp.au.debian.org/debian/ wheezy main

with line:

    deb http://ftp.au.debian.org/debian/ wheezy main contrib non-free

now update the apt library:

    sudo apt-get update
    apt-get install firmware-b43-installer

then restart the computer and the wifi light should come on

###### example for the ralink rt3290 wireless network device (https://wiki.debian.org/rt3290):

edit the `/etc/apt/sources.list` file. replace line

    deb http://ftp.au.debian.org/debian/ wheezy main contrib non-free

with line:

    deb http://fpt.au.debian.org/debian/ wheezy-backports main contrib non-free

now update the apt library:

    sudo aptitude update
    sudo aptitude -t wheezy-backports install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') firmware-ralink

then restart the computer and the wifi light should come on

#### make sure the time gets automatically updated

    sudo apt-get install ntp

#### get the touchpad mouse on a laptop working

first find out the brand:

    egrep -i 'synap|alps|etps' /proc/bus/input/devices

for synaptics touchpad mouses, install the firmware:

    sudo apt-get install xf86-input-synaptics

now check all the settings for the touchpad:

    synclient -l

turn on the edge scrolling:

    synclient VertEdgeScroll=1

turn on tap-clicking:

    synclient FastTaps=1
    synclient TapButton1=1
    synclient ClickPad=0

turn on middle click (when both left and right are clicked simultaneously):

    synclient EmulateMidButtonTime=100

if you want these changes to be permanent then you need to edit the configuration file (`/usr/share/X11/xorg.conf.d/50-synaptics.conf`)

https://wiki.debian.org/SynapticsTouchpad

https://wiki.archlinux.org/index.php/Touchpad_Synaptics

update the relevant section to look like this: 

    Section "InputClass"
        Identifier "touchpad catchall"
        Driver "synaptics"
        MatchIsTouchpad "on"
        Option "VertEdgeScroll" "1"
        Option "FastTaps" "1"
        Option "TapButton" "1"
        Option "ClickPad" "0"
        Option "EmulateMidButtonTime" "100"
        MatchDevicePath "/dev/input/event*"
    EndSection

#### setup fstab to mount external usb drive on boot

there is an example at `~/.fstab`

first use gparted to find the device path (in this case it is `/dev/sdb`), then get the uuid:

    sudo blkid /dev/sdb1
    /dev/sdb1: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" TYPE="ext4" LABEL="drivename" 

add a line to `/etc/fstab` to create the home directory:

    UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /home/bob ext4 defaults 0 2

make sure the home directory exists:

    sudo mkdir /home/bob

and make sure that it is owned by bob, and bob's group:

    sudo chown bob:bob /home/bob

you may need to do this again after the pc has rebooted and once the drive is mounted in place

do the same to create the backup directory:

    UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /home/bob_backup ext4 defaults 0 2

make sure the backup home directory exists:

    sudo mkdir /home/bob_backup

and make sure that it is owned by bob, and bob's group:

    sudo chown bob:bob /home/bob_backup

again you may need to do this again after the pc has rebooted and once the drive is mounted in place

#### install subversion for setting up repositories:

    sudo apt-get install subversion

ensure that the config repository is checked out to the home dir:

    vi /home/bob/.svn/entries

if the file does not exist then:

    svn checkout svn+ssh://bob@pcname/home/bob/repositories/config /home/bob

#### update the dns ip address

    sudo ln -sf ~/.resolv.conf /etc/resolv.conf

#### install and configure the full version of vim:

    sudo apt-get install vim

link the .vimrc file to the /root/ directory so that sudo vi has colors too:

    sudo ln -sf /home/bob/.vimrc /root/.vimrc

#### stop the cursor from blinking (if using the gui gnome terminal)

    gconftool-2 --set /apps/gnome-terminal/profiles/Default/cursor_blink_mode --type string off

#### setup the tty font size to avoid eye strain:

    sudo dpkg-reconfigure console-setup

choose

    UTF-8, Combined - Latin, Fixed or Terminus, size 10x20

if you choose one of the framebuffer font sizes then you will need to install the following extra package to make it work:

    sudo apt-get install kbd

and then check if the console-tools package is removed with messy config files left behind:

    dpkg-query -l console-tools

if so then purge it:

    sudo dpkg --purge console-tools

now update the font settings for the system:

    setupcon

install the terminus font for use in xterm:

    sudo apt-get install xfonts-terminus

#### test the column width in xterm. if it is too small then set it to some big number:

    stty cols 1800

link the `.bashrc` file to the `/root/` directory so that root has a pretty prompt:

    sudo ln -sf /home/bob/.bashrc /root/.bashrc

check if there are any differences between crontab files:

    diff /etc/crontab ~/.crontab

then link the global crontab to the local crontab:

    sudo ln -sf /home/bob/.crontab /etc/crontab

#### install a browser to surf the net and look for answers when stuck (and cat pictures)

remove the nasty default iceweasel web browser and all its dependencies:

    sudo apt-get autoremove --purge iceweasel

chromium seems a bit quicker than mozilla iceweasel and supports things like pjax which iceweasel 17.0.9 does not first check to see what the latest version of chromium is called:

    apt-cache search chromium

you should see:

    chromium-browser - Chromium browser - transitional dummy package
    chromium-browser-l10n - chromium-browser language packages - transitional dummy package

install both of these:

    sudo apt-get install chromium-browser chromium-browser-l10n

#### install flash so that you can watch videos

first update /etc/apt/sources.list. replace line:

    deb http://ftp.au.debian.org/debian/ wheezy main

with line:

    deb http://ftp.au.debian.org/debian/ wheezy main contrib non-free

now update the apt library:

    sudo apt-get update

then install flash:

    sudo apt-get install flashplugin-nonfree 

#### install xorg so that startx works

    sudo apt-get install xinit

#### also install the mutter window manager:

    sudo apt-get install mutter

install a program to inspect the window manager

    sudo apt-get install wmctrl

echo the name of the current window manager:

    wmctrl -m

set up grub to boot to tty when the pc is turned on:

alter `GRUB_CMDLINE_LINUX_DEFAULT` from `"quiet"` to `"text"` in `/etc/default/grub`, like so:

    GRUB_CMDLINE_LINUX_DEFAULT="text"

now update grub to take effect on next reboot:

    sudo update-grub

make sure that the screen configuration file exists

    vi ~/.screenrc

#### make sure ssh is installed and linked to the correct sshd_config:

    sudo apt-get install ssh
    sudo ln -s /home/bob/.ssh/sshd_config /etc/ssh/sshd_config

if there are no ssh keys then generate some:

    ssh-keygen -t dsa

place them in `~/.ssh/`

copy the public key `~/.ssh/id_das.pub` into `~/.ssh/authorized_keys` on the remote machines to login to

#### make sure the hosts file for this computer is correct

note that `/etc/hosts` cannot be removed first if you want to use sudo:

    sudo ln -sf /home/bob/.hosts_pcname /etc/hosts

#### set up the network interfaces file to point at the dot file on the hard drive 

    sudo ln -sf /home/bob/.interfaces_pcname /etc/network/interfaces

#### install the full version of vlc to watch movies:

    sudo apt-get install vlc

#### install skype

first setup debian multiarch so that it can run a 32 bit program on a 64 bit cpu:

    sudo dpkg --add-architecture i386
    sudo apt-get update

remove any previous installations of skype:

    sudo apt-get remove --purge skype skype-bin skype:i386 skype-bin:i386
	rm -rf ~/.Skype

install dependencies:

    sudo apt-get install pavucontrol

run pavucontrol and make sure the desired microphone is set as "fallback" - this actually means "default"!!!

then, download the i386 package into the /tmp/ dir and install:

    cd /tmp
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    sudo dpkg -i skype-install.deb
    sudo apt-get -f install

restart to get skype to recognize pulseaudio and all should be fine

    sudo shutdown -r 0

#### install vuze to get some torrent files

    sudo apt-get install vuze

#### install zip so that you can zip/unzip saved files

    sudo apt-get install zip

#### install apache2

    sudo apt-get install apache2

make sure a2enmod is available

    locate a2enmod

apache may place it in `/usr/sbin`, which is not on the `$PATH`. if so then add it to `/usr/bin`, which is on the `$PATH`:

    ln -s /usr/sbin/a2enmod /usr/bin/a2enmod

now turn on the rewrite module:

    sudo a2enmod rewrite

link the apache2 config file to that in the local user dir:

    sudo ln -sf /home/bob/.000-default /etc/apache2/sites-available/default

make sure the server has a name:

    echo "ServerName myservername" > /tmp/servername
    sudo mv /tmp/servername /etc/apache2/conf.d/

set the correct permissions on `/var/www` (http://superuser.com/questions/19318)

    sudo chgrp -R www-data /var/www
    sudo chmod -R g+w /var/www

make the directory and all directories below it "set gid", so that all new files and directories created under `/var/www` are owned by the `www-data` group

    sudo find /var/www -type d -exec chmod 2775 {} \;

find all files in /var/www and add read and write permission for owner and group

    sudo find /var/www -type f -exec chmod ug+rw {} \;

now add your own user to the www-data group

    sudo usermod -a -G www-data bob

log out and log back in to be able to make changes

#### set up an ssl certificate for your website

this allows you to send and receive encrypted data over http. first generate a private rsa (key) file

    cd /etc/ssl/private
    openssl genrsa -out myhostname.com.key -des3 2048

enter a password. you will need this every time you restart your webserver. note that this file is never shared with anyone (not even the ssl certificate provider).

now generate the certificate signing request (csr) file

    cd /etc/ssl/
    openssl req -new -key myhostname.com.key -out myhostname.com.csr

for each of the prompts enter:

* password - the same one used when generating the key
* country name - short-country-name
* state or province - statename
* city - cityname
* organisation name - myorg
* organisational unit name - my pet project
* common name - *.myhostname.com/CN=myhostname.com
* email - bob@gmail.com
* challenge password - to leave this field blank insert a full-stop and press enter
* optional company name - to leave this field blank insert a full-stop and press enter

navigate to startssl.com (or any other certificate authority) and sign up to get a p12 key to login

select the option to generate a webserver certificate

skip the step where you generate the private key (csr file) since this was already done at the start of the process

copy your csr file and paste it into the website

add the http://www.myhostname.com domain (if you want more subdomains you'll probably have to pay though)

download the crt file and place it in `/etc/ssl/certs/myhostname.com.crt`

if there is an intermediate certificate (pem) file then download it and place it in `/etc/ssl/certs/myhostname.com.intermediate.pem`

concatenate the crt and pem files:

    cat myhostname.com.crt myhostname.com.intermediate.pem > x
    mv x myhostname.com.crt

secure all file permissions:

    chmod 640 /etc/ssl/private/myhostname.com.key
    chmod 644 /etc/ssl/certs/myhostname.com*

now open the apache2 config file (either `/etc/apache2/sites-enabled/000-default` or `/etc/apache2/sites-enabled/default-ssl`) and add/update the following lines

    <VirtualHost *:443>
	    SSLEngine on
        SSLCertificateKeyFile /etc/ssl/private/myhostname.com.key
        SSLCertificateFile /etc/ssl/certs/myhostname.com.crt
        SSLCertificateChainFile /etc/ssl/certs/myhostname.com.intermediate.pem
        ServerSignature On
    </VirtualHost>

note that there may be other lines intersperced between these, however this does not matter, so long as these lines exist in this order somewhere within the file then the server certificate will work.

now restart apache

    sudo /etc/init.d/apache2 restart

and enter the password for your certificate key file

if you see a fail message then apache may be using a default password. this is done using the `SSLPassPhraseDialog` var, in one of the config files. if you can't find which one then grep will find it for you:

    cd /etc/apache2
    grep -ir sslpassphrasedialog *

once you find this entry then comment it out with a #. then restart apache2 again and make sure it doesn't fail this time.

to check that the certificate is recognized open your browser and navigate to `https://myhostname.com`. right click on the padlock and make sure the date of the certificate begins on the current date.

#### install mysql

    sudo apt-get install mysql-server mysql-client

use the root password found in `/home/bob/notes/pw.gpg`

link the mysql config file to that in the local user dir:

    sudo ln -sf /home/bob/.my.cnf /etc/mysql/my.cnf

#### install php5 (cli and apache):

    sudo apt-get install php5

link the config files to that in the local user dir:

    sudo ln -sf /home/bob/.php.ini /etc/php5/cli/php.ini
    sudo ln -sf /home/bob/.php.ini /etc/php5/apache2/php.ini

if interactive mode does not work for php5-cli (this is the case for debian 7 as php does not come with readline support) then use facebook's phpsh instead:

    sudo apt-get install python # phpsh runs on python so this must be installed first
    cd /tmp
    wget https://github.com/facebook/phpsh/zipball/master
    unzip phpsh-master.zip
    cd phpsh-master
    sudo cp -r src /etc/phpsh # phpsh seems to complain unless it resides at /etc/phpsh
    sudo ln -s /etc/phpsh/phpsh /usr/bin/phpsh # put phpsh on the $PATH
    phpsh # test it out. you should not see any errors

if you see any warnings when running phpsh that there are extensions (eg `PHP Warning:  PHP Startup: Unable to load dynamic library /usr/lib/php5/20100525/http.so`) then install them like so:

    sudo apt-get install php-http make
    sudo pecl install pecl_http

after this you should not see any warnings when running phpsh

#### install phpmyadmin (has mysql, php and apache as dependencies)

    sudo apt-get install phpmyadmin

#### install freenet and start it downloading

    cd ~/Downloads
    wget https://freenet.googlecode.com/files/new_installer_offline_1457.jar -O new_installer_offline.jar

now create a directory to store freenet in:

    sudo mkdir /usr/local/src/freenet
    sudo chown bob:bob /usr/local/src/freenet
    java -jar new_installer_offline.jar

save to `/usr/local/src/freenet` and allow overwriting of this directory

once the install has finished, put freenet on the $PATH so that it can be run from anywhere:

    sudo ln -s /usr/local/src/freenet/run.sh /usr/bin/freenet

now navigate to `127.0.0.1:8888` on chromium to configure freenet

to make freenet run when the pc boots:

    sudo crontab -e

then type:

    @reboot sudo -u bob /usr/bin/freenet start 2>&1 >/tmp/freenet.cron-out

#### install bitcoind from source

instructions for debian wheezy: http://wp.geeklab.com.ar/gl-en/2013/03/11/how-to-install-bitcoin-0-8-0-on-debian-wheezy-amd64/

first add the line `deb-src http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu precise main` to `/etc/apt/sources.list`

then add the key in apt:

    sudo gpg --keyserver hkp://subkeys.pgp.net --recv-keys D46F45428842CE5E
    sudo gpg --export --armor D46F45428842CE5E | sudo apt-key add --

then update the repository info on the local machine:

    sudo apt-get update
    sudo apt-get install dpkg-dev qt4-qmake libdb5.1++-dev libqt4-dev libqrencode-dev libminiupnpc-dev libboost-test1.49-dev zlib1g lib32z1 libc6-i386 debhelper devscripts bash-completion libboost-system-dev libssl-dev pkg-config libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-test-dev

create the directory to house the bitcoin source and download the source:

    sudo mkdir /usr/local/src/bitcoin
    cd /usr/local/src/bitcoin
    sudo apt-get source bitcoin
    cd bitcoin-* # will cd into something like the bitcoin-0.8.5 dir

add the following lines to the top of the `/usr/local/src/bitcoin/bitcoin-*/debian/changelog` file:

    "bitcoin (0.8.5-wheezy1) wheezy; urgency=low

      * Mark for wheezy.

     -- Matt Corallo <matt@bluematt.me>  Sat, 16 Sep 2013 14:02:00 -0400
    "
now compile bitcoind and install:

    sudo /usr/local/src/bitcoin/bitcoin-*/debian/rules clean
    sudo /usr/local/src/bitcoin/bitcoin-*/debian/rules binary
    cd /usr/local/src/bitcoin
    sudo dpkg -i bitcoind_0.8.5-wheezy1_amd64.deb

don't install bitcoin-qt - use the armory client as its much better. if you did want to install it though:

    sudo dpkg -i bitcoin-qt_0.8.5-wheezy1_amd64.deb 

now make sure that `~/.bitcoin/bitcoin.conf` exists and has an rpc password, then test bitcoind:

    bitcoind &
    bitcoind getinfo

if all is working then you should see a json output. if there is no output then this could be because the daemon has not yet connected to its peers, if so then just wait a while and try again.

now make bitcoind run when the pc boots:

    sudo crontab -e

then type:

    @reboot sudo -u bob /usr/bin/bitcoind 2>&1 >/tmp/bitcoind.cron-out

save and exit

note that bitcoind probably can't run as root without the above setup

#### install the armory client for bitcoin on debian from source

    cd /usr/local/src/

install git to download the source, and any missing dependencies for the installation process:

    sudo apt-get install git-core build-essential pyqt4-dev-tools swig libqtcore4 libqt4-dev python-qt4 python-dev python-twisted python-psutil
    sudo git clone git://github.com/etotheipi/BitcoinArmory.git
    cd BitcoinArmory
    sudo make

that should finish without errors in about 5 minutes. now create a file called `/usr/local/src/BitcoinArmory/run.sh` and put the following code in it:

    #!/bin/sh
    python /usr/local/src/BitcoinArmory/ArmoryQt.py

finally, put armory on the `$PATH` so that it can be run from anywhere:

    sudo ln -s /usr/local/src/BitcoinArmory/run.sh /usr/bin/armory

#### download znort987's blockparser program

    sudo apt-get install libssl-dev build-essential g++-4.4 libboost-all-dev libsparsehash-dev git-core perl
    cd /usr/local/src/
    sudo git clone git://github.com/znort987/blockparser.git
    cd blockparser
    sudo make

finally, add the blockparser program to the `$PATH` so that it can be run from anywhere:

    sudo ln -s /usr/local/src/blockparser/parser /usr/bin/blockparser

#### install sx

first install libbitcoin (https://github.com/spesmilo/libbitcoin):

    sudo apt-get install build-essential autoconf automake libtool libboost-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev
    autoreconf -i
    ./configure --enable-leveldb
    make
    sudo make install
    sudo ldconfig

#### make sure email is installed and configured

    sudo apt-get install exim4
    sudo dpkg-reconfigure exim4-config

choose options:

1. internet site; mail is sent and received directly using SMTP 
2. The 'mail name' is the domain name used to 'qualify' mail addresses without a domain name = myhostname.com
3. Please enter a semicolon-separated list of IP addresses. = 127.0.0.1 ; ::1
4. Please enter a semicolon-separated list of recipient domains = myhostname.com
5. Please enter a semicolon-separated list of recipient domains for which this system will relay mail = empty
6. Please enter a semicolon-separated list of IP address ranges for which this system will unconditionally relay mail, functioning as a smarthost = empty
7. Keep number of DNS-queries minimal (Dial-on-Demand)? <no>
8. mbox format in /var/mail/
9. Split configuration into small files? = <No>
10. Root and postmaster mail recipient = empty

exim should then restart

now make sure that emails get through:

    echo "sending to gmail at mm:ss" | mail -s "mm:ss" bob@gmail.com

if you don't get an email then ensure that the dns ip is correct in `/etc/resolv.conf`

#### install the ssh notifier (sends an email to me whenever someone logs in via ssh)

    sudo chown root:root ~/.ssh_notifications.php
    sudo chmod 755 ~/.ssh_notifications.php
    sudo ln -sf ~/.ssh_notifications.php /usr/local/scripts/ssh_notifications.php
    sudo ln -sf ~/.sshd /etc/pam.d/sshd

test by ssh-ing to the machine and ensuring that an email comes through

if the time is incorrect in the email then php's date and time will need to be updated in php.ini:

    date.timezone = "country/cityname"

#### install a c compiler

    sudo apt-get install gdb

#### install python's package installer

    sudo apt-get install python-pip

#### install banshee to load music and videos onto an ipod

    sudo apt-get install banshee

#### compile ffmpeg from source to convert video for ipod (http://trac.ffmpeg.org/wiki/UbuntuCompilationGuide)

first make sure any existing installation of ffmpeg is completely gone

    sudo apt-get --purge remove ffmpeg

then get all the dependencies

    sudo apt-get install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libx11-dev libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev libmp3lame-dev

create the necessary directories:

    mkdir ~/ffmpeg_build ~/ffmpeg_sources ~/bin

if working on an x64 machine, install yasm assembler (must be >= 1.2.0)

    wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
    tar xzvf yasm-1.2.0.tar.gz
    cd ~/yasm-1.2.0
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
    make
    make install
    make distclean

copy `yasm` binaries to the `PATH`:

    sudo cp ~/bin/*asm* /usr/bin/

compile all known encoders:

    cd ~/ffmpeg_sources
    wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
    tar xjvf last_x264.tar.bz2
    cd x264-snapshot*
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
    make
    make install
    make distclean
    sudo cp ~/bin/x264 /usr/bin/

    cd ~/ffmpeg_sources
    wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
    unzip fdk-aac.zip
    cd mstorsjo-fdk-aac*
    autoreconf -fiv
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
    make
    make install
    make distclean

    cd ~/ffmpeg_sources
    wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
    tar xzvf opus-1.1.tar.gz
    cd opus-1.1
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
    make
    make install
    make distclean

    cd ~/ffmpeg_sources
    wget http://webm.googlecode.com/files/libvpx-v1.3.0.tar.bz2
    tar xjvf libvpx-v1.3.0.tar.bz2
    cd libvpx-v1.3.0
    ./configure --prefix="$HOME/ffmpeg_build" --disable-examples
    make
    make install
    make clean

now compile ffmpeg with all the above encoders:

    cd ~/ffmpeg_sources
    wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
    tar xjvf ffmpeg-snapshot.tar.bz2
    cd ffmpeg
    PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
    export PKG_CONFIG_PATH
    ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --enable-x11grab
    make
    make install
    make distclean
    hash -r

    sudo cp ~/bin/ff* /usr/bin/

now encode to mov like so:

    ffmpeg -i input.mp4 -c:v libx264 -preset fast -profile:v baseline out.mov

#### install scrot to take screenshots from the command line

    sudo apt-get install scrot

run it with a 2 second delay at 100% quality:

    scrot '%Y%m%d_1.png' -q100 -d2 -e 'mv $f /tmp/'

#### install a vpn client compatible with cisco anyconnect

    sudo apt-get install openconnect vpnc

run it, so that you can access the restricted network through your browser

    echo 'the!!password' | sudo openconnect -u 'the!!username' --passwd-on-stdin vpn.hostname.com

then enter the username and password when promted

#### install a vpn client compatible with microsoft point-to-point vpn

    sudo apt-get install pptp-linux

now configure it to connect to your resired private network (called vpn0 here)

    sudo ln -sf /home/bob/.ppp_vpn0_pw /etc/ppp/chap-secrets
    sudo ln -sf /home/bob/.ppp_vpn0_settings /etc/ppp/peers/vpn0

make sure that the .ppp* files have the following properties:

    -rw------- 1 bob bob <size> <datetime> /home/bob/.ppp_vpn0_pw
    -rw-r--r-- 1 bob bob <size> <datetime> /home/bob/.ppp_vpn0_settings

now you can start and stop ppp vpn any time like so:

    sudo pon vpn0
    sudo poff vpn0

to check if the vpn interface is working:

    ifconfig | grep ppp

and you should see an entry (might need to wait a half a minute after starting the vpn if the connection is very slow).

to diagnose errors:

    pon vpn0 debug dump logfd 2 nodetach

extra help here: http://pptpclient.sourceforge.net/howto-debian.phtml

#### install an rdp client so you can connect to windows machines

    sudo apt-get install remmina

run it from the commandline and put in the details of an rdp server (eg a windows 8 pc). attempt to connect and see if there are any certificate errors:

    $ remmina
    connected to 192.168.0.x:3389
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @           WARNING: CERTIFICATE NAME MISMATCH!           @
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    The hostname used for this connection (192.168.0.x) 
    does not match the name given in the certificate:
    remote-pc-name
    A valid certificate for the wrong name should NOT be trusted!

if you see this warning then use whatever value you see reported instead of remote-pc-name in the server textbox in remmina, then edit your `/etc/hosts` so that remmina can find the ip address of this server. make sure a line like so exists:

    192.168.0.x remote-pc-name

###### to copy a file between your local debian 7 pc and the remote windows machine

first create a new dir to share with the remote machine. it is best not to use an existing dir for this otherwise the remote machine will be very slow to load the file list, and also anything in that dir which you may not have wanted to share will be automatically shared.

    mkdir ~/remmina_share0

now make sure that no remmina rdp connection is open for the profile you are editing, and edit the remote desktop preferences in remmina like so:

**basic tab**

- share folder - set to the new `~/remmina_share0` dir

**advanced tab**

- sound: local
- security: rdp
- make sure to click save.

after this, navigate to `my computer` on the remote windows desktop and click refresh. the shared folder should appear under `other devices` and drives right next to local disk `c:`

#### finally clean up any straggling packages:

    sudo apt-get autoremove
    sudo apt-get clean
