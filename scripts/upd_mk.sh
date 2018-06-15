export https_proxy=https://proxyout.lanl.gov:8080
export http_proxy=http://proxyout.lanl.gov:8080
eval $(ssh-agent -s)
ssh-add ~/.ssh/mysshkey
cd /github/fp
git pull
source /opt/Xilinx/Vivado/2016.2/settings64.sh
source /opt/Xilinx/SDK/2016.2/settings64.sh
make NAME=digitizer bit
make NAME=current_voltage bit
make NAME=lockin_sweep all
sh scripts/image.sh scripts/debian-rus.sh rus.img 1024
mount -t ext4 -o loop,offset=15728640 rus.img /mnt/rus
cp rus.img /media/sf_Install
