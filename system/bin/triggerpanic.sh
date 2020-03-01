#!/system/bin/sh

panic_prop=`getprop sys.asus.triggerpanic`

if [ "$panic_prop" == "1" ]; then
	echo "[Debug] LogTool Trigger Panic" > /proc/asusevtlog
	sleep 2
	echo panic > /proc/asusdebug-prop
else
	exit
fi
