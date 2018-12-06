
# Update system
apt -y update
apt -y uprade
apt -y dist-upgrade

# Basic utilities
apt -y install curl
apt -y install git
apt -y install yadm
apt -y install vim
apt -y install pandoc
apt -y install texlive-full

# Before running this script, enable contrib and non-free in /etc/apt/sources.lst
# Nvidia graphics drivers
dpkg --add-architecture i386
apt install firmware-linux nvidia-driver nvidia-settings nvidia-xconfig

# Misc
apt -y install cowsay
