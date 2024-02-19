# Make the disk writable
	if [ -d /boot/firmware ]; then
	  (sudo mount -o remount,rw / 2>/dev/null ; sudo mount -o remount,rw /boot/firmware 2>/dev/null)
	else
	  mount -o remount,rw /boot
	  mount -o remount,rw /
	fi
