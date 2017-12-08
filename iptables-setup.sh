#!/bin/bash

# put all firewall rules here
# useful resource: thegeekstuff.com/2011/06/iptables-rules-examples

if [ "$EUID" -ne 0 ]; then
    echo "this script must be run as root"
    exit 1
fi

firewall_on=true

# delete all rules everything (no ports blocked yet)
iptables -F

if [ $firewall_on = true ]; then
    # block all ports and continue
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP
else
    # allow everything
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    echo -e "\nthe new firewall rules are:\n"
    iptables-save
    exit
fi

# defines $IF0 and $MYLAN
. ~/.my_ips

################################################################################
### BEGIN localhost RULES

iptables -A INPUT -i lo -p all -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -o lo -p all -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT

### END localhost RULES
################################################################################

################################################################################
### BEGIN DNS RULES

# allow outgoing dns requests (and connection responses)
iptables -A OUTPUT -o "$IF0" -p udp -d mydns --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o "$IF0" -p tcp -d mydns --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p udp -s mydns --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p tcp -s mydns --sport 54 -m state --state ESTABLISHED -j ACCEPT

### END DNS RULES
################################################################################


################################################################################
### BEGIN PING RULES

# allow ping unconditionally
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

### END PING RULES
################################################################################


################################################################################
### BEGIN SSH RULES

# allow incoming ssh conections from MYLAN (and connection responses)
iptables -A INPUT -i "$IF0" -p tcp -s "$MYLAN" --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o "$IF0" -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# allow outgoing ssh connections to MYLAN (and connection responses)
iptables -A OUTPUT -o "$IF0" -p tcp -d "$MYLAN" --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### END SSH RULES
################################################################################


################################################################################
### BEGIN HTTP/S RULES
### turn these off/on depending on whether you are testing or in production

# allow incoming http/s on MYLAN (and responses)
iptables -A INPUT -i "$IF0" -p tcp -s "$MYLAN" -m multiport --dports 80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o "$IF0" -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j ACCEPT

### END HTTP/S RULES
################################################################################


################################################################################
### BEGIN APT-GET RULES

iptables -A OUTPUT -p tcp -d "ftp.debian.org" --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s "ftp.debian.org" -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d "security.debian.org" --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s "security.debian.org" -m state --state ESTABLISHED -j ACCEPT

### END APT-GET RULES
################################################################################


################################################################################
### BEGIN SMB/CIFS RULES

# allow a remote dir on a windows machine (192.168.100.100) to be mounted locally
# grep -i netbios /etc/services
# gives ports 137,138,139. 445 is also needed

iptables -A INPUT -i "$IF0" -p tcp -s 192.168.100.100 -m multiport --sports 137,138,139,445 -j ACCEPT
iptables -A OUTPUT -o "$IF0" -p tcp -d 192.168.100.100 -m multiport --dports 137,138,139,445 -j ACCEPT
iptables -A INPUT -i "$IF0" -p udp -s 192.168.100.100 -m multiport --sports 137,138,139,445 -j ACCEPT
iptables -A OUTPUT -o "$IF0" -p udp -d 192.168.100.100 -m multiport --dports 137,138,139,445 -j ACCEPT

### END SMB/CIFS RULES
################################################################################


################################################################################
### BEGIN GIT RULES

# git repo lives on port 1111 on 192.168.101.101
iptables -A OUTPUT -o "$IF0" -p tcp -d 192.168.101.101 --dport 1111 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p tcp -s 192.168.101.101 --sport 1111 -m state --state ESTABLISHED -j ACCEPT

### END GIT RULES
################################################################################


################################################################################
### BEGIN email RULES

iptables -A OUTPUT -o "$IF0" -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p tcp --sport 25 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o "$IF0" -p tcp --dport 587 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i "$IF0" -p tcp --sport 587 -m state --state RELATED,ESTABLISHED -j ACCEPT

### END email RULES
################################################################################

################################################################################
### BEGIN NTP RULES

iptables -A OUTPUT -p udp --sport 123 --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 123 -m state --state ESTABLISHED,RELATED -j ACCEPT

### END NTP RULES
################################################################################

echo -e "\nthe new firewall rules are:\n"
iptables -S
