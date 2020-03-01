#!/system/bin/sh

# generate /sdcard/LOGS/GetProvider.txt
am broadcast -a com.asus.DumpSettingsValues -p com.android.settings

# savelog
SAVE_LOG_ROOT=/data/media/0/save_log
BUSYBOX=busybox

# check mount file
umask 0;
sync
############################################################################################
# check wifi / BT / Modem property to disable sepolicy
# wifi : property = 1
setenforce_wifi_prop=`getprop persist.vendor.asus.wlanfwdbg` 
# Modem and BT : property bit 2 = 1
setenforce_modem_and_bt_prop=`getprop persist.vendor.modem.restart`
modem_bit=$((setenforce_modem_and_bt_prop & 0x2))
# Modem : property = 1
setenforce_modem_prop=`getprop persist.vendor.asus.qxdmlog.enable`

if [ "$setenforce_wifi_prop" == "1" ] || [ "$setenforce_modem_prop" == "1" ] || [ "$modem_bit" == "2" ]; then
	setenforce_prop=`getprop sys.asus.setenforce`
	if [ "$setenforce_prop" != "1" ]; then
		setprop sys.asus.setenforce 1
		echo "setenforce: permissive" > /proc/asusevtlog
	fi
fi
############################################################################################
# create savelog folder (UTC)
SAVE_LOG_PATH="$SAVE_LOG_ROOT/`date +%Y_%m_%d_%H_%M_%S`"
mkdir -p $SAVE_LOG_PATH
setprop asus.savelogmtp.folder $SAVE_LOG_PATH
chmod -R 777 $SAVE_LOG_PATH
chmod -R 777 $SAVE_LOG_ROOT
echo "mkdir -p $SAVE_LOG_PATH"
############################################################################################
mkdir $SAVE_LOG_PATH/recovery
cp -r /cache/recovery/* $SAVE_LOG_PATH/recovery/
getprop > $SAVE_LOG_PATH/getprop.txt
echo "getprop > $SAVE_LOG_PATH/getprop.txt"
############################################################################################
# save cmdline
cat /proc/cmdline > $SAVE_LOG_PATH/cmdline.txt
echo "cat /proc/cmdline > $SAVE_LOG_PATH/cmdline.txt"
############################################################################################
# save mount table
cat /proc/mounts > $SAVE_LOG_PATH/mounts.txt
echo "cat /proc/mounts > $SAVE_LOG_PATH/mounts.txt"
############################################################################################
# save space used status
df > $SAVE_LOG_PATH/df.txt
echo "df > $SAVE_LOG_PATH/df.txt"
###########################################################################################
# save last_kmsg
cp -r /sys/fs/pstore/ $SAVE_LOG_PATH
echo "cp -r /sys/fs/pstore/ $SAVE_LOG_PATH"
###########################################################################################
# save network info
cat /proc/net/route > $SAVE_LOG_PATH/route.txt
echo "route -n > $SAVE_LOG_PATH/route.txt"
ifconfig -a > $SAVE_LOG_PATH/ifconfig.txt
echo "ifconfig -a > $SAVE_LOG_PATH/ifconfig.txt"
############################################################################################
# save software version
echo "AP_VER: `getprop ro.build.display.id`" > $SAVE_LOG_PATH/version.txt
echo "CP_VER: `getprop gsm.version.baseband`" >> $SAVE_LOG_PATH/version.txt
echo "BT_VER: `getprop bt.version.driver`" >> $SAVE_LOG_PATH/version.txt
echo "WIFI_VER: `getprop wifi.version.driver`" >> $SAVE_LOG_PATH/version.txt
echo "GPS_VER: `getprop gps.version.driver`" >> $SAVE_LOG_PATH/version.txt
echo "BUILD_DATE: `getprop ro.build.date`" >> $SAVE_LOG_PATH/version.txt
############################################################################################
# save property setting
echo "persist.vendor.asus.wlanfwdbg = $setenforce_wifi_prop" > $SAVE_LOG_PATH/enforce_prop.txt
echo "persist.vendor.modem.restart = $setenforce_modem_and_bt_prop" >> $SAVE_LOG_PATH/enforce_prop.txt
echo "persist.vendor.asus.qxdmlog.enable = $setenforce_modem_prop" >> $SAVE_LOG_PATH/enforce_prop.txt
echo "modem bit = $modem_bit" >> $SAVE_LOG_PATH/enforce_prop.txt
############################################################################################
# save load kernel modules
lsmod > $SAVE_LOG_PATH/lsmod.txt
echo "lsmod > $SAVE_LOG_PATH/lsmod.txt"
############################################################################################
# save process now
setprop sys.asus.savelogs.ps $SAVE_LOG_PATH
############################################################################################
# save kernel message
dmesg > $SAVE_LOG_PATH/dmesg.txt
echo "dmesg > $SAVE_LOG_PATH/dmesg.txt"
############################################################################################
# copy data/tombstones to data/media
ls -R -l /data/tombstones/ > $SAVE_LOG_PATH/ls_data_tombstones.txt
mkdir $SAVE_LOG_PATH/tombstones
cp -r /data/tombstones/* $SAVE_LOG_PATH/tombstones/
echo "cp -r /data/tombstones $SAVE_LOG_PATH"
############################################################################################
ls -R -lZa /asdf > $SAVE_LOG_PATH/ls_asdf.txt
############################################################################################
# copy data/tombstones to data/media
#busybox ls -R -l /tombstones/mdm > $SAVE_LOG_PATH/ls_tombstones_mdm.txt
mkdir -p /data/tombstones/dsps
mkdir -p /data/tombstones/lpass
mkdir -p /data/tombstones/mdm
mkdir -p /data/tombstones/modem
mkdir -p /data/tombstones/wcnss
chown system.system /data/tombstones/*
chmod 771 /data/tombstones/*
############################################################################################
# copy Debug Ion information to data/media
mkdir $SAVE_LOG_PATH/ION_Debug
cp -r /d/ion/* $SAVE_LOG_PATH/ION_Debug/
############################################################################################
# copy data/logcat_log to data/media
ls -R -lZ /data/logcat_log/ > $SAVE_LOG_PATH/ls_data_logcat_log.txt
mkdir $SAVE_LOG_PATH/logcat_log
mkdir $SAVE_LOG_PATH/logcat_log/btsnoop
cp -r /data/logcat_log/logcat* $SAVE_LOG_PATH/logcat_log
cp -r /data/logcat_log/kernel* $SAVE_LOG_PATH/logcat_log
cp -r /data/logcat_log/capture* $SAVE_LOG_PATH/logcat_log
echo "cp -r /data/logcat_log $SAVE_LOG_PATH"
############################################################################################
# copy asdf/logcat_log to data/media
cp -r /asdf/asdf_logcat/ $SAVE_LOG_PATH
echo "cp -r /asdf/asdf_logcat $SAVE_LOG_PATH"
############################################################################################
# copy /asdf/ASUSEvtlog.txt
cp -r /asdf/ASUSEvtlog.txt $SAVE_LOG_PATH
cp -r /asdf/ASUSEvtlog_old.txt $SAVE_LOG_PATH
cp -r /asdf/ASUSEvtlog.tar.gz $SAVE_LOG_PATH
cp -r /asdf/ASDF $SAVE_LOG_PATH
cp -r /asdf/sensor/dumpsys_sensorservice.txt $SAVE_LOG_PATH
echo "cp -r /asdf/ASUSEvtlog.txt $SAVE_LOG_PATH"
############################################################################################
cp -r /data/vendor/wifi/hostapd/hostapd.conf $SAVE_LOG_PATH
echo "cp -r /data/vendor/wifi/hostapd/hostapd.conf $SAVE_LOG_PATH"
cp -r /data/misc/wifi/p2p_supplicant.conf $SAVE_LOG_PATH
echo "cp -r /data/misc/wifi/p2p_supplicant.conf $SAVE_LOG_PATH"

# copy wlan fw logs
cp -r /data/vendor/wifi/wlan_logs/ $SAVE_LOG_PATH
echo "cp -r /data/vendor/wifi/wlan_logs $SAVE_LOG_PATH"

# copy wlan configstore
cp -r /data/misc/wifi/WifiConfigStore.xml $SAVE_LOG_PATH
echo "cp -r /data/misc/wifi/WifiConfigStore.xml $SAVE_LOG_PATH"
############################################################################################
# mv /data/anr to data/media
ls -R -l /data/anr > $SAVE_LOG_PATH/ls_data_anr.txt
mkdir $SAVE_LOG_PATH/anr
cp -r /data/anr/* $SAVE_LOG_PATH/anr/
echo "cp -r /data/anr $SAVE_LOG_PATH"
############################################################################################
# mv /data/media/ap_ramdump  to data/media
ls -R -l /data/media/ap_ramdump > $SAVE_LOG_PATH/ls_data_media_ap_ramdump.txt
mkdir $SAVE_LOG_PATH/ap_ramdump
cp -r /data/media/ap_ramdump/* $SAVE_LOG_PATH/ap_ramdump/
echo "cp -r /data/media/ap_ramdump $SAVE_LOG_PATH"
############################################################################################
date > $SAVE_LOG_PATH/date.txt
echo "date > $SAVE_LOG_PATH/date.txt"
############################################################################################
cat /proc/meminfo > $SAVE_LOG_PATH/meminfo.txt
############################################################################################
# save debug report
dumpsys -t 30 > $SAVE_LOG_PATH/dumpsys.txt
echo "dumpsys > $SAVE_LOG_PATH/dumpsys.txt"
############################################################################################
lsof > $SAVE_LOG_PATH/lsof.txt
echo "lsof > $SAVE_LOG_PATH/lsof.txt"
############################################################################################
# copy /sdcard/LOGS/GetProvider.txt
if [ -e /sdcard/LOGS/GetProvider.txt ]; then
	cp /sdcard/LOGS/GetProvider.txt $SAVE_LOG_PATH
fi
############################################################################################
BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports
#("bugreport" is files prefix)
dumpstate -q -d -z -o $BUGREPORT_PATH/bugreport
#move bugreport files to /data/media/0/ASUS/LogUploader/general/sdcard
for filename in $BUGREPORT_PATH/*; do
    name=${filename##*/}
    cp $filename $SAVE_LOG_PATH/$name
    rm $filename
done
rm -r /asdf/ASDF/ASDF.*
############################################################################################
ps -eo f,s,uid,pid,ppid,c,pri,ni,bit,sz,%mem,%cpu,wchan,tty,time,cmd > $SAVE_LOG_PATH/ps.txt
ps -A -T > $SAVE_LOG_PATH/ps_thread.txt
############################################################################################

ls -R -l /data/vendor/ramdump/ssr_ramdump > $SAVE_LOG_PATH/ls_ssr_ramdump.txt
cp -r /data/vendor/ramdump/ssr_ramdump/ $SAVE_LOG_PATH
echo "cp -r /data/vendor/ramdump/ssr_ramdump $SAVE_LOG_PATH"

# copy /asdf/SubSysMedicalTable.txt
cp -r /asdf/SubSysMedicalTable.txt $SAVE_LOG_PATH
cp -r /asdf/SubSysMedicalTable_old.txt $SAVE_LOG_PATH
echo "cp -r /asdf/SubSysMedicalTable.txt $SAVE_LOG_PATH"

#copy batinfo to sdcard
cp /dev/block/platform/soc/1d84000.ufshc/by-name/batinfo $SAVE_LOG_PATH/power_event/

############################################################################################
micropTest=`cat /sys/class/switch/pfs_pad_ec/state`
if [ "${micropTest}" = "1" ]; then
    date > $SAVE_LOG_PATH/microp_dump.txt
    cat /d/gpio >> $SAVE_LOG_PATH/microp_dump.txt
    echo "cat /d/gpio > $SAVE_LOG_PATH/microp_dump.txt"
    cat /d/microp >> $SAVE_LOG_PATH/microp_dump.txt
    echo "cat /d/microp > $SAVE_LOG_PATH/microp_dump.txt"
fi
############################################################################################
# copy /data/misc/bluetooth/logs/ to data/media
ls -R -l /data/misc/bluetooth/logs > $SAVE_LOG_PATH/ls_data_btsnoop.txt
cp -r /data/misc/bluetooth/logs/* $SAVE_LOG_PATH/logcat_log/btsnoop/
ls -R -l /data/vendor/ssrdump > $SAVE_LOG_PATH/ls_data_ssrdump.txt
cp -r /data/vendor/ssrdump/* $SAVE_LOG_PATH/logcat_log/btsnoop/
echo "cp -r /data/misc/bluetooth/logs $SAVE_LOG_PATH/logcat_log/btsnoop/"
############################################################################################
# sync data to disk 
# 1015 sdcard_rw
chmod -R 777 $SAVE_LOG_PATH
chmod -R 777 $SAVE_LOG_ROOT
sync
# tar log
wait_cmd=`tar -cf $SAVE_LOG_PATH.tar . -C $SAVE_LOG_PATH`
rm -rf $SAVE_LOG_PATH
mkdir $SAVE_LOG_PATH
mv $SAVE_LOG_PATH.tar $SAVE_LOG_PATH

# QXDM log
#add to stop and then capture modem log problem
if [ -d "/data/vendor/ramdump/diag_logs/" ]; then
    enableQXDM=`getprop persist.vendor.asus.qxdmlog.enable`
    if [ "${enableQXDM}" = "1" ]; then
        setprop persist.vendor.asus.qxdmlog.enable 0
        echo "Turn off QXDM log for savelogmtp"
        sleep 1
        sync
    fi

    ls -R -l /data/vendor/ramdump/diag_logs > $SAVE_LOG_PATH/ls_diag_logs.txt
    cp -r /data/vendor/ramdump/diag_logs/ $SAVE_LOG_PATH
    echo "cp -r /data/vendor/ramdump/diag_logs/ $SAVE_LOG_PATH"
    rm -r /data/vendor/ramdump/diag_logs/
    echo "rm -r /data/vendor/ramdump/diag_logs/"
    sync
    
    #add to stop and then capture modem log problem
    if [ "${enableQXDM}" = "1" ]; then
        setprop persist.vendor.asus.qxdmlog.enable 1
        echo "Turn on QXDM log for savelogmtp"
    fi
fi
chmod -R 777 $SAVE_LOG_PATH
chmod -R 777 $SAVE_LOG_ROOT
sync

am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///storage/emulated/0/
setprop persist.asus.savelogs.complete 1
setprop persist.asus.savelogs.complete 0
############################################################################################
setenforce_prop=`getprop sys.asus.setenforce`
if [ "$setenforce_prop" == "1" ]; then
	setprop sys.asus.setenforce 0
	echo "setenforce: enforcing" > /proc/asusevtlog
	sleep 1
	echo "[Reboot] AsusLogTool reboot device" > /proc/asusevtlog
	#reboot
fi
############################################################################################
