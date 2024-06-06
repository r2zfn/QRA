#!/bin/bash
#
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

dmrgateway=/etc/dmrgateway

if [ "$(id -u)" != "0" ]; then
    echo -e "You need to be root to run this command...\n"
exit 1
fi


echo "Set rpi-rw"
if [ -d /boot/firmware ]; then
	  (sudo mount -o remount,rw / 2>/dev/null ; sudo mount -o remount,rw /boot/firmware 2>/dev/null)
else
	  mount -o remount,rw /boot
	  mount -o remount,rw /
fi
wpsd-update
wpsd-upgrade
sed -i 's|gitBranchSbin|#gitBranchSbin|' /usr/local/sbin/pistar-daily.cron
sed -i 's|git --work-tree=/usr/local/sbin|#git --work-tree=/usr/local/sbin|' /usr/local/sbin/pistar-daily.cron
sed -i 's|git_update /usr/local/sbin|#git_update /usr/local/sbin|' /usr/local/sbin/pistar-update

if cat /root/XLXHosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure XLXHosts"
  echo "496;38.180.66.135;4001" >> /root/XLXHosts.txt
  echo "895;46.138.248.163;4004" >> /root/XLXHosts.txt
fi

if cat /root/P25Hosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure P25Hosts"
  echo "496	p25.qra-team.online	41001" >> /root/P25Hosts.txt
fi

if cat /root/DMR_Hosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure DMR_Hosts"
  echo "XLX_496       0000    38.180.66.135     passw0rd        62030" >> /root/DMR_Hosts.txt
  echo "XLX_895       0000    46.138.248.163     passw0rd        62030" >> /root/DMR_Hosts.txt
fi

if cat /root/YSFHosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure YSFHosts"
  echo "00496;XLX496;XLX-QRA;38.180.66.135;42000;004;https://qra-team.online;0" >> /root/YSFHosts.txt
fi

echo "Configuring INI files"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Startup=.*/Startup=496/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Enabled=.*/Enabled=1/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Port=.*/Port=62030/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Password=.*/Password=passw0rd/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Slot=.*/Slot=1/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^TG=.*/TG=9/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Base=.*/Base=94000/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Module=.*/Module=A/' "${dmrgateway}"
echo "------------"

curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/r2zfn/QRA/main/HostFilesUpdate.sh

checkAlterPistar=$(grep -s SimplexLogic /etc/svxlink/svxlink.conf)
if [[ "" == $(grep -s SimplexLogic /etc/svxlink/svxlink.conf) ]]; then
  echo "Running pistar-update"
  pistar-update
else
  echo "This is AlterPiStar"
  /usr/local/sbin/HostFilesUpdate.sh
  systemctl restart dmrgateway.service
  systemctl restart mmdvmhost.service
fi

curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/r2zfn/QRA/main/HostFilesUpdate.sh

echo " "
echo -e "${GRN}------------>  Обновление завершено...${NC}"
echo " "
echo -e "${GRN}------------>  Добро Пожаловать в QRA-Team!${NC}"
exit 0
