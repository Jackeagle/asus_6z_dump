#!/system/bin/sh

# Delete /data/logcat_log
enableLogcat=`getprop persist.asus.startlog`
#if test "$enableLogcat" = "1"; then
if [ "${enableLogcat}" = "1" ]; then
	wait_cmd=`setprop persist.asus.startlog 0`
	echo "Turn off logcat service for clear log"
	sleep 3
	sync
	logcat_turn_off=1
fi


#rm logcat log
wait_cmd=`rm -rf /data/logcat_log/logcat*`
wait_cmd=`rm -rf /data/logcat_log/kernel*`
sync
echo "rm -rf /data/logcat_log/logcat and kernel"

if [ "${logcat_turn_off}" = "1" ]; then
	wait_cmd=`setprop persist.asus.startlog 1`
	logcat_turn_off=0
	echo "Turn on logcat service for clear log"
fi

########################################################################
# Delete SD card log 

if [ -d "/sdcard/save_log/" ]; then
	wait_cmd=`rm -rf /sdcard/save_log`
	sync
	am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///storage/emulated/0/ -p com.android.providers.media
fi
########################################################################
echo "[AsusLogTool] clear log" > /proc/asusevtlog
