#!/system/bin/sh

android_boot=`getprop sys.boot_completed`
downloadmode=`getprop persist.sys.downloadmode.enable`
platform=`getprop ro.build.product`
unlocked=`getprop atd.unlocked.ready`
stage=`getprop ro.boot.id.stage`
setenforce_modem_and_bt_prop=`getprop persist.vendor.modem.restart`
imei1=`getprop persist.radio.device.imei`
imei2=`getprop persist.radio.device.imei2`

# ZS630KL Q
if [ "$platform" != "ZS630KL" ] && [ "$platform" != "ASUS_I01WD" ]; then
	echo "It is not ZS630KL !!"
	exit
fi

# check boot complete
timeout=0
while [ "$android_boot" -ne "1" ]; do
	timeout=$(($timeout+1))
	if [ $timeout == 300 ]; then
		echo "[Debug] check boot complete timeout exit ($timeout)!!" > /proc/asusevtlog
		exit
	fi
	echo "boot not ready !!"
	sleep 1
	android_boot=`getprop sys.boot_completed`
done
echo "boot ready ($android_boot)!!"

# disable coredump
debug_prop=`getprop persist.debug.trace`
if [ "$debug_prop" == "1" ]; then
	setprop persist.debug.trace 0
	debug_prop=`getprop persist.debug.trace`
	echo "setprop persist.debug.trace $debug_prop"
fi

# check MP & unlock
if [ "$stage" == "7" ] && [ "$unlocked" == "0" ]; then
	# IMEI
	imei_result1=`grep -c "$imei1" /system/etc/IMEI_whitelist.txt`
	#echo "[Debug] check imei1 : $imei_result1" > /proc/asusevtlog
	imei_result2=`grep -c "$imei2" /system/etc/IMEI_whitelist.txt`
	#echo "[Debug] check imei2 : $imei_result2" > /proc/asusevtlog
	if [ "$imei_result1" == "1" ] || [ "$imei_result2" == "1" ]; then
		echo "[Debug] whitelist imei found !!" > /proc/asusevtlog
	else
		# RSASD 
		# wait 1 sec to get /sdcard/dat.bin
		sync
		sleep 1
		sync
		myShellVar=`(rsasd)`
		sleep 1
		sync
		#myShellVar=`$(rsasd)`
		echo "[Debug] myShellVar = ($myShellVar)!!" > /proc/asusevtlog
		echo "[Debug] whitelist imei not found!!" > /proc/asusevtlog
		if [ "$myShellVar" == "13168" ]; then
			echo "[Debug] check rsasd : pass" > /proc/asusevtlog
		else
			echo "[Debug] check rsasd : fail" > /proc/asusevtlog
			echo "MP lock exit ($stage) !!"
			exit
		fi
	fi
fi

# check downloadmode flag & devcfg
devcfg_diff=0
modem_bit=$((setenforce_modem_and_bt_prop & 0x2))
if [ "$downloadmode" == "1" ] || [ "$modem_bit" == "2" ]; then
	echo asussetenforce:0 > /proc/rd
	mkdir -p /asdf/devcfg
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
	dd if=/dev/block/sde15 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
	dd if=/dev/block/sde35 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
	devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
	devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
	devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
	if [ "$devcfgcheck_a" != "$devcfgsystem" ] || [ "$devcfgcheck_b" != "$devcfgsystem" ]; then
		devcfg_diff=1
	fi
else
	exit
fi

# load devcfg
success=0
if [ "$devcfg_diff" == "1" ]; then
	if [ `getenforce` == "Permissive" ]; then
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde15
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde35
		sync
		# Check
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
		dd if=/dev/block/sde15 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
		dd if=/dev/block/sde35 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
		devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
		devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
		devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
		if [ "$devcfgcheck_a" != "$devcfgsystem" ] || [ "$devcfgcheck_b" != "$devcfgsystem" ]; then
			dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde15
			dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde35
			sync
			# check again
			dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
			dd if=/dev/block/sde15 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
			dd if=/dev/block/sde35 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
			devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
			devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
			devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
			if [ "$devcfgcheck_a" == "$devcfgsystem" ] && [ "$devcfgcheck_b" == "$devcfgsystem" ]; then
				success=1
			fi
		else
			success=1
		fi
	fi
fi

# Reboot
if [ "$devcfg_diff" == "1" ]; then
	echo "[Reboot] Enable DLmode & Load devcfg ($platform:$success)" > /proc/asusevtlog
	reboot
else
	# remove binary
	if [ -e /asdf/devcfg/ ]; then
		rm -rf /asdf/devcfg/
		echo "Remove devcfg"
	fi
	echo asussetenforce:1 > /proc/rd
	exit
fi
echo asussetenforce:1 > /proc/rd
