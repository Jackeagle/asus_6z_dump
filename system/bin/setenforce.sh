#!/system/bin/sh

android_boot=`getprop sys.boot_completed`
setenforce_prop=`getprop sys.asus.setenforce`

# check boot complete
if [ "$android_boot" == "" ] || ["$android_boot" == "0"]; then
	echo "boot not ready !!"
	exit
fi

if [ "$setenforce_prop" == "" ]; then
	exit
fi

if [ "$setenforce_prop" == "1" ]; then
	echo asussetenforce:0 > /proc/rd
else
	echo asussetenforce:1 > /proc/rd
fi

echo "setenforce_prop : $setenforce_prop"
