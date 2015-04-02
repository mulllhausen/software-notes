debian wheezy routing setup
==============

use these instructions to view/edit routing rules via the commandline.

#### show the current route setup

    $ route

which is equivalent to

    $ netstat -r

both these resolve ip addresses to domain names if possible. if you just want to see ip addresses, then do:

    $ route -n

which is equivalent to

    $ netstat -rn

#### what does it all mean?

    $ route
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
    default         192-168-2-1.tpg 0.0.0.0         UG        0 0          0 wlan0
    xyz.lnk.te      192-168-2-1.tpg 255.255.255.255 UGH       0 0          0 wlan0
    111.128.51.62   192-168-2-1.tpg 255.255.255.255 UGH       0 0          0 wlan0
    link-local      *               255.255.0.0     U         0 0          0 wlan0
    192.168.0.0     192.168.0.104   255.255.255.0   UG        0 0          0 ppp0
    192.168.0.104   *               255.255.255.255 UH        0 0          0 ppp0
    192.168.2.0     *               255.255.255.0   U         0 0          0 wlan0

    $ route -n
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
    0.0.0.0         192.168.2.1     0.0.0.0         UG        0 0          0 wlan0
    111.123.51.62   192.168.2.1     255.255.255.255 UGH       0 0          0 wlan0
    111.128.51.62   192.168.2.1     255.255.255.255 UGH       0 0          0 wlan0
    169.254.0.0     0.0.0.0         255.255.0.0     U         0 0          0 wlan0
    192.168.0.0     192.168.0.104   255.255.255.0   UG        0 0          0 ppp0
    192.168.0.104   0.0.0.0         255.255.255.255 UH        0 0          0 ppp0
    192.168.2.0     0.0.0.0         255.255.255.0   U         0 0          0 wlan0

here we have lots of routes. the default gateway is `192.168.2.1` - ie this is the ip address of the router on the lan and is accessible via the `wlan0` interface. the route is active (`U` = up) and is a gateway (`G`). and since the netmask is `0.0.0.0` then all other routes must pass through this one. also note that `default` is synonymous with ip address `0.0.0.0` - ie "everything".

the route to `xyz.lnk.te` (ip address `111.123.51.62`) is a host link (`H` flag). this destination can be reached by gateway `192.168.2.1` and since the netmask is `255.255.255.255` then this is not a range, but rather a single ip address.

the [`link-local` route](http://en.wikipedia.org/wiki/Link-local_address) is a rule which applies to all addresses in the range `169.254.1.0` to `169.254.254.255`. basically anything in this range is not allowed out of the lan.

the first `ppp0` route in the table above specifies that any request to an ip address in the range `192.168.0.0` to `192.168.0.255` will be forwarded to `192.168.0.104`. the netmask `255.255.255.0` specifies that the first 3 bytes of the ip address must be exactly as specified (`192.168.0`) and the final byte can be anything (`0` to `255`).

#### to delete a route

say you wanted to delete the following route rule:

    111.123.51.62   192.168.1.1     255.255.255.255 UGH       0 0          0 wlan0

you have to be very specific, otherwise you could end up deleting other similar routes as well:

    $ route del -net 111.123.51.62 netmask 255.255.255.255 gw 192.168.1.1 wlan0

#### to add a route

route to a single ip address:

    $ sudo route add -net 192.168.5.5 netmask 255.255.255.255 gw 192.168.0.104

this means that when you ping `192.168.5.5` your computer will send it to the `192.168.0.104` gateway and then it will be redirected to `192.168.5.5` in the lan on the other side of the gateway. but note that this route does not enable you to ping `192.168.5.6` or `192.168.5.7`.

add a route to a range of ip addresses:

    $ sudo route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.104

this means that when you ping any address in the range `192.168.0.0` to `192.168.0.255` it gets redirected via the `192.168.0.104` gateway and then redirected to the specifiec ip address (eg `192.168.0.17`) on the lan which is on the other side of the gateway. if you add this route it will make the previous one superfluous but both will still exist.
