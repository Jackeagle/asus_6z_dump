#!/system/bin/sh

android_boot=`getprop sys.boot_completed`
android_reboot_prop='sys.asus.android_reboot'
android_reboot=`getprop $android_reboot_prop`

# Check boot completed
if [ "$android_boot" == "1" ]; then
	if [ "$android_reboot" == "" ]; then
		setprop $android_reboot_prop 0
		echo "ASDF: 1st boot_completed...." > /proc/asusevtlog
	else
		android_reboot=$(($android_reboot+1))
		setprop $android_reboot_prop $android_reboot
		echo "[Debug]: Android restart....($android_reboot)" > /proc/asusevtlog
	fi
fi
