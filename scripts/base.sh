#!/bin/sh -e

###################################
############## INSTALLS AND UPDATES
###################################

## Use this example to 'hold back' packages you don't want to update
#echo "linux hold" | dpkg --set-selections

# Edit listchanges 'frontend=text' so it doesn't freeze our non-interactive script when there's an imoportant changelog
cat >/etc/apt/listchanges.conf <<EOL
[apt]
frontend=text
email_address=root
confirm=0
save_seen=/var/lib/apt/listchanges.db
which=news
EOL

# First we have to update our keyring or else our upgrades won't work
rm -rf /var/lib/apt/lists
apt-get  update
apt-get -y --force-yes install kali-archive-keyring

# Install helpful things
apt-get update
apt-get -y install zlib1g-dev libreadline-gplv2-dev curl unzip vim nfs-client

# Now we can upgrade
apt-get -y --force-yes upgrade
apt-get -y --force-yes dist-upgrade

# Now install the kali-linux-full metapackage to install all tools that normally come with the ISO
## run with these options to get around updates that requires user input.
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confnew" install kali-linux-full

# Clean up
apt-get -y autoremove
apt-get -y clean

###############################
############## USERS AND GROUPS
###############################

# Create vagrant user
useradd -G sudo -p $(perl -e'print crypt("vagrant", "vagrant")') -m -s /bin/bash -N vagrant

# Create vagrant group (used later by our vagrant.sh script)
groupadd vagrant

# Set up sudo (thanks to codeship.io)
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Change Root password to standard Kali settings
echo -e "toor\ntoor" | passwd root

# Auto Login as root
cat >>/etc/gdm3/daemon.conf <<EOL
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = root
EOL

###############################
#################### NETWORKING
###############################

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces