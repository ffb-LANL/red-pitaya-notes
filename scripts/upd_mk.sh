export https_proxy=https://proxyout.lanl.gov:8080
export http_proxy=http://proxyout.lanl.gov:8080
eval $(ssh-agent -s)
ssh-add ~/.ssh/mysshkey
cd /github/fp
git pull
source /opt/Xilinx/Vivado/2016.2/settings64.sh
source /opt/Xilinx/SDK/2016.2/settings64.sh
make NAME=red_pitaya_0_92 all
sh scripts/image.sh scripts/debian-ecosystem.sh red-pitaya-ecosystem-0.95-debian-8.5-armhf.img 1024
cp red-pitaya-ecosystem-0.95-debian-8.5-armhf.img /media/sf_Install
