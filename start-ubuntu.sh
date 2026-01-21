#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD

UBUNTU_PATH="$HOME/ubuntu"

proot --link2symlink -0 -r ~/ubuntu -b /dev -b /proc -b /sys -w /root /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; exec /bin/bash --login"
