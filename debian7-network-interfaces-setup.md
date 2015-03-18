debian wheezy network interfaces setup
==============

these instructions only apply to setting up network interfaces via the commandline.

#### check to see what interface hardware is available

    $ ifconfig -a

for the remainder of these notes, the following output is assumed:

    eth0 ...
    lo ...
    wlan0 ...

#### check to see what driver the kernel is using for each of these interfaces

    $ ls /sys/class/net/wlan0/device/driver/module/drivers
    $ ls /sys/class/net/eth0/device/driver/module/drivers

#### first things first - remove conflicting packages

network manager is known to interfere with other network setup tools in debian so remove this:

    $ sudo apt-get remove --purge network-manager

if wicd is installed this could also interfere with manual configuration of networks, so remove this too:

    $ sudo apt-get remove --purge wicd

#### configure eth0 with dhcp

first install a dhcp client:

    $ sudo apt-get install pump

now add the following lines to `/etc/network/interfaces`:

    iface eth0 inet dhcp

and make sure that all other parts of the `eth0` block are removed.

check if the `eth0` device is up:

    $ sudo ip link show eth0

if the device is up then this command will produce an output like:

    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

if the device is not up then bring the device up like so:

    $ sudo ip link set eth0 up

now bring the interface (not to be confused with the device) up and check its ip address on the network:

    $ sudo ifup eth0
    $ ip addr show eth0
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
        inet 192.168.1.4/24 brd 192.168.1.255 scope global eth0

you should now be able to ping your access point (router), eg:

    $ ping 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_req=1 ttl=254 time=1.40 ms
    64 bytes from 192.168.1.1: icmp_req=2 ttl=254 time=2.06 ms
    64 bytes from 192.168.1.1: icmp_req=3 ttl=254 time=3.55 ms
    ^C
    --- 192.168.1.1 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2003ms
    rtt min/avg/max/mdev = 1.401/2.338/3.551/0.900 ms

#### configure eth0 with a static ip address

now add the following lines to `/etc/network/interfaces`:

    iface eth0 inet static
        address 192.168.1.20
        netmask 255.255.255.0
        gateway 192.168.1.1
        dns-nameservers 8.8.8.8 8.8.4.4

and make sure that all other parts of the `eth0` block are removed.

check if the `eth0` device is up:

    $ sudo ip link show eth0

if the device is up then this command will produce an output like:

    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

if the device is not up then bring the device up like so:

    $ sudo ip link set eth0 up

now bring the interface (not to be confused with the device) up and check its ip address on the network:

    $ sudo ifup eth0
    $ ip addr show eth0
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
        inet 192.168.1.20/24 brd 192.168.1.255 scope global eth0

you should now be able to ping your access point (router), eg:

    $ ping 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_req=1 ttl=254 time=1.40 ms
    64 bytes from 192.168.1.1: icmp_req=2 ttl=254 time=2.06 ms
    64 bytes from 192.168.1.1: icmp_req=3 ttl=254 time=3.55 ms
    ^C
    --- 192.168.1.1 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2003ms
    rtt min/avg/max/mdev = 1.401/2.338/3.551/0.900 ms

#### enable wifi

install the following programs:

    $ sudo apt-get install iwlist wpasupplicant

check if the wifi device is up:

    $ sudo ip link show wlan0

if you see something like this:

    3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisk mq state DOWN mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

then the device is down (the led is probably not shining on the pc case). bring it up and check the status again:

    $ sudo ip link set wlan0 up
    $ sudo ip link show wlan0
    3: wlan0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT qlen 1000
        link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

the status shows the device (but not the interface) is up. the led on the pc case should now be shining (if there is one).

scan for wireless networks in range:

    $ sudo iwlist wlan0 scan | grep -i ssid

#### connect to an ssid using `wpa_supplicant` directly from the commandline

create the wpa supplicant configuration file if it does not already exist like so:

    $ cd /etc/wpa_supplicant/
	# note the use of single quotes in the following line. this is very important
    # as it prevents the shell from evaluating and converting symbols. for example
    # if your ssid or password had a $$ in it then the shell would evaluate this
    # as the process id and then compute the passphrase using that, which would
    # fail to connect to your access point.
    $ wpa_passphrase 'my_ssid' 'the wireless password' >> wpa_supplicant.conf
    $ sudo chown root:root wpa_supplicant.conf
    $ sudo chmod 600 wpa_supplicant.conf # ensure only root can read this file

now edit the `/etc/wpa_supplicant/wpa_supplicant.conf` file. make sure the line starting with `#psk` contains your actual password. if it does not then you need to regenerate the `wpa_supplicant.conf` file using `wpa_passphrase`.

make sure `/etc/wpa_supplicant/wpa_supplicant.conf` has the following information:

    ap_scan=1
    ctrl_interface=DIR=/var/run/wpa_supplicant
    ctrl_interface_group=0

    network={
        proto=WPA2
        pairwise=CCMP
        group=CCMP
        key_mgmt=WPA-PSK
        ssid="myssid"
        #psk="xxxxx" 
        psk=a_long_string_of_hex
    }

now edit `/etc/network/interfaces` to include a block for `wlan0`:

    # auto wlan0
    iface wlan0 inet static
        address 192.168.1.21
        netmask 255.255.255.0
        gateway 192.168.1.1
        dns-nameservers 8.8.8.8 8.8.4.4

keep `auto wlan0` commented out for now. if the wlan0 interface cannot be brought up and you reboot then you could get stuck in an infinite loop here and never reach the command prompt.

now bring up the interface:

    $ sudo ifup wlan0

and connect to the access point:

    $ sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

an output like this is a good sign that everything is working ok:

    ioctl[SIOCSIWENCODEEXT]: Invalid argument
    ioctl[SIOCSIWENCODEEXT]: Invalid argument
    wlan0: Trying to associate with 00:60:64:4c:37:fc (SSID='myssid' freq=2412 MHz)
    wlan0: Associated with 00:60:64:4c:37:fc
    wlan0: WPA: Key negotiation completed with 00:60:64:4c:37:fc [PTK=CCMP GTK=CCMP]
    wlan0: CTRL-EVENT-CONNECTED - Connection to 00:60:64:4c:37:fc completed (auth) [id=0 id_str=]

if you can ping the router then you have done everything correctly:

    ping 192.168.1.1

but if it says

    connect: Network is unreachable

then you don't have a connection to the router. if this happens then the first thing to do is to check the light is on for the wifi card. if it is on then have a look through this for help - http://unix.stackexchange.com/questions/190754/wpa-supplicant-nightmares

#### connect to an ssid using `wpa_supplicant` via `/etc/network/interfaces`

on debian 7 it is possible to have wpa_supplicant called automatically by placing the relevant instructions in `/etc/network/interfaces` like so:

    iface wlan0 inet static
        wpa-ssid "myssid"
        wpa-psk "my wpa2 password"
        wpa-ap-scan 1
        wpa-proto WPA2
        wpa-pairwise CCMP
        wpa-group CCMP
        wpa-key-mgmt WPA-PSK
        address 192.168.1.50
        netmask 255.255.255.0
        gateway 192.168.1.1
        dns-nameservers 8.8.8.8 8.8.4.4

rename `/etc/wpa_supplicant/wpa_supplicant.conf` so that it no longer gets called:

    $ sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.old

now bring up the device:

    $ sudo ip link set wlan0 up

and bringing up the interface should automatically connect to your wifi access point without the need to manually run wpa_supplicant:

    $ sudo ifup wlan0

if you can ping the router then you have done everything correctly:

    ping 192.168.1.1

but if it says

    connect: Network is unreachable

then you don't have a connection to the router. if this happens then the first thing to do is to check the light is on for the wifi card. if it is on then have a look through this for help - http://unix.stackexchange.com/questions/190754/wpa-supplicant-nightmares
