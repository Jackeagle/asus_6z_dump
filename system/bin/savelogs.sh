#!/system/bin/sh

# generate /sdcard/LOGS/GetProvider.txt
am broadcast -a com.asus.DumpSettingsValues -p com.android.settings

#MODEM_LOG
MODEM_LOG=/data/media/0/ASUS/LogUploader/modem
#TCP_DUMP_LOG
TCP_DUMP_LOG=/data/media/0/ASUS/LogUploader/TCPdump
#GENERAL_LOG
GENERAL_LOG=/data/media/0/ASUS/LogUploader/general/sdcard
#LOG_PATH
LOG_PATH=/data/media/0/ASUS/LogUploader

#Dumpsys folder
DUMPSYS_DIR=/data/media/0/ASUS/LogUploader/dumpsys

#BUSYBOX=busybox

savelogs_prop=`getprop persist.asus.savelogs`
is_tcpdump_status=`getprop init.svc.tcpdump-warp`
isBetaUser=`getprop persist.asus.mupload.enable`

save_general_log() {
        #setprop persist.asus.startlog 0
        cp -r /sys/fs/pstore/ $GENERAL_LOG
	############################################################################################
	# save cmdline
	cat /proc/cmdline > $GENERAL_LOG/cmdline.txt
	echo "cat /proc/cmdline > $GENERAL_LOG/cmdline.txt"
	############################################################################################
	# save mount table
	cat /proc/mounts > $GENERAL_LOG/mounts.txt
	echo "cat /proc/mounts > $GENERAL_LOG/mounts.txt"
	############################################################################################
	getenforce > $GENERAL_LOG/getenforce.txt
	echo "getenforce > $GENERAL_LOG/getenforce.txt"
	############################################################################################
	# save property
	getprop > $GENERAL_LOG/getprop.txt
	echo "getprop > $GENERAL_LOG/getprop.txt"
	############################################################################################
	# save network info
	cat /proc/net/route > $GENERAL_LOG/route.txt
	echo "cat /proc/net/route > $GENERAL_LOG/route.txt"
	ifconfig -a > $GENERAL_LOG/ifconfig.txt
	echo "ifconfig -a > $GENERAL_LOG/ifconfig.txt"
	############################################################################################
	# save software version
	echo "AP_VER: `getprop ro.build.display.id`" > $GENERAL_LOG/version.txt
	echo "CP_VER: `getprop gsm.version.baseband`" >> $GENERAL_LOG/version.txt
	echo "BT_VER: `getprop bt.version.driver`" >> $GENERAL_LOG/version.txt
	echo "WIFI_VER: `getprop wifi.version.driver`" >> $GENERAL_LOG/version.txt
	echo "GPS_VER: `getprop gps.version.driver`" >> $GENERAL_LOG/version.txt
	echo "BUILD_DATE: `getprop ro.build.date`" >> $GENERAL_LOG/version.txt
	############################################################################################
	# save load kernel modules
	lsmod > $GENERAL_LOG/lsmod.txt
	echo "lsmod > $GENERAL_LOG/lsmod.txt"
	############################################################################################
	# save process now
	ps -eo f,s,uid,pid,ppid,c,pri,ni,bit,sz,%mem,%cpu,wchan,tty,time,cmd > $GENERAL_LOG/ps.txt
	ps -A -T > $GENERAL_LOG/ps_thread.txt
	############################################################################################
	# save kernel message
	dmesg > $GENERAL_LOG/dmesg.txt
	echo "dmesg > $GENERAL_LOG/dmesg.txt"
	############################################################################################
	# copy data/log to data/media
	#$BUSYBOX ls -R -l /data/log/ > $GENERAL_LOG/ls_data_log.txt
	#mkdir $GENERAL_LOG/log
	#$BUSYBOX cp /data/log/* $GENERAL_LOG/log/
	#echo "$BUSYBOX cp /data/log $GENERAL_LOG"
	############################################################################################
	# copy data/tombstones to data/media
	ls -R -l /data/tombstones/ > $GENERAL_LOG/ls_data_tombstones.txt
	mkdir $GENERAL_LOG/tombstones
	cp /data/tombstones/* $GENERAL_LOG/tombstones/
	echo "cp /data/tombstones $GENERAL_LOG"
	rm -r /data/tombstones/*
	############################################################################################
	ls -R -lZa /asdf > $GENERAL_LOG/ls_asdf.txt
	############################################################################################
	# copy Debug Ion information to data/media
	mkdir $GENERAL_LOG/ION_Debug
	cp -r /d/ion/* $GENERAL_LOG/ION_Debug/
	############################################################################################
	# copy data/logcat_log to data/media
	#busybox ls -R -l /data/logcat_log/ > $GENERAL_LOG/ls_data_logcat_log.txt
	#$BUSYBOX cp -r /data/logcat_log/ $GENERAL_LOG
	#echo "$BUSYBOX cp -r /data/logcat_log $GENERAL_LOG"
	mkdir $GENERAL_LOG/logcat_log
	ls -R -lZ /data/logcat_log/ > $GENERAL_LOG/ls_data_logcat_log.txt
	cp -r /data/logcat_log/logcat* $GENERAL_LOG/logcat_log
	cp -r /data/logcat_log/kernel* $GENERAL_LOG/logcat_log
        cp -r /data/logcat_log/capture* $GENERAL_LOG/logcat_log
	echo "cp -r /data/logcat_log $GENERAL_LOG"
	rm -r /data/logcat_log/logcat.txt.*
	rm -r /data/logcat_log/logcat-events.txt.*
	rm -r /data/logcat_log/logcat-kernel.*
	rm -r /data/logcat_log/logcat-radio.txt.*
	rm -r /data/logcat_log/kernel.log.*
	############################################################################################
	# copy asdf/logcat_log to data/media
	cp -r /asdf/asdf_logcat/ $GENERAL_LOG
	echo "cp -r /asdf/asdf_logcat $GENERAL_LOG"
	############################################################################################
	# copy ASUSEvtlog.txt
	cp -r /asdf/ASUSEvtlog.txt $GENERAL_LOG
	cp -r /asdf/ASUSEvtlog_old.txt $GENERAL_LOG
	cp -r /asdf/ASUSEvtlog.tar.gz $GENERAL_LOG
	cp -r /asdf/ASDF $GENERAL_LOG
	cp -r /asdf/sensor/dumpsys_sensorservice.txt $GENERAL_LOG
	echo "cp -r /asdf/ASUSEvtlog.txt $GENERAL_LOG"
	############################################################################################
	# copy /sdcard/wlan_logs/
	cp -r /data/vendor/wifi/wlan_logs/cnss_fw_logs_current.txt $GENERAL_LOG
	echo "cp -r /data/vendor/wifi/wlan_logs/cnss_fw_logs_current.txt $GENERAL_LOG"
	############################################################################################
	if [ ".$isBetaUser" == ".1" ]; then
		cp -r /data/misc/wifi/WifiConfigStore.xml $GENERAL_LOG
		echo "cp -r /data/misc/wifi/WifiConfigStore.xml $GENERAL_LOG"
		# copy /data/misc/wifi/wpa_supplicant.conf
		# copy /data/misc/wifi/hostapd.conf
		# copy /data/misc/wifi/p2p_supplicant.conf
		ls -R -l /data/misc/wifi/ > $GENERAL_LOG/ls_wifi_asus_log.txt
		cp -r /data/misc/wifi/wpa_supplicant.conf $GENERAL_LOG
		echo "cp -r /data/misc/wifi/wpa_supplicant.conf $GENERAL_LOG"
		cp -r /data/vendor/wifi/hostapd/hostapd.conf $GENERAL_LOG
		echo "cp -r /data/vendor/wifi/hostpad/hostapd.conf $GENERAL_LOG"
		cp -r /data/misc/wifi/p2p_supplicant.conf $GENERAL_LOG
		echo "cp -r /data/misc/wifi/p2p_supplicant.conf $GENERAL_LOG"
	fi
	############################################################################################
	# mv /data/anr to data/media
	ls -R -l /data/anr > $GENERAL_LOG/ls_data_anr.txt
	mkdir $GENERAL_LOG/anr
	cp -r /data/anr/* $GENERAL_LOG/anr/
	echo "cp -r /data/anr $GENERAL_LOG"
	rm -r /data/anr/*
    ############################################################################################
    # [BugReporter]Save ps.txt to Dumpsys folder
    #ps -t -p -P > $DUMPSYS_DIR/ps.txt
    ############################################################################################
        date > $GENERAL_LOG/date.txt
	echo "date > $GENERAL_LOG/date.txt"
        micropTest=`cat /sys/class/switch/pfs_pad_ec/state`
	if [ "${micropTest}" = "1" ]; then
	    date > $GENERAL_LOG/microp_dump.txt
	    cat /d/gpio >> $GENERAL_LOG/microp_dump.txt
            echo "cat /d/gpio > $GENERAL_LOG/microp_dump.txt"
            cat /d/microp >> $GENERAL_LOG/microp_dump.txt
            echo "cat /d/microp > $GENERAL_LOG/microp_dump.txt"
	fi
	############################################################################################
	cat /proc/meminfo > $GENERAL_LOG/meminfo.txt
	############################################################################################
	# save debug report
	dumpsys -t 30 > $GENERAL_LOG/dumpsys.txt
	echo "dumpsys > $GENERAL_LOG/dumpsys.txt"
	############################################################################################
	df > $GENERAL_LOG/df.txt
	echo "df > $GENERAL_LOG/df.txt"
	############################################################################################
	# copy /sdcard/LOGS/GetProvider.txt
	if [ -e /sdcard/LOGS/GetProvider.txt ]; then
		cp /sdcard/LOGS/GetProvider.txt $GENERAL_LOG
	fi
	############################################################################################
        lsof > $GENERAL_LOG/lsof.txt

        mkdir $GENERAL_LOG/ap_ramdump
        cp -r /data/media/ap_ramdump/* $GENERAL_LOG/ap_ramdump/

        mkdir $GENERAL_LOG/recovery
        cp -r /cache/recovery/* $GENERAL_LOG/recovery/
        #setprop persist.asus.startlog 1

        BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports
        #("bugreport" is files prefix)
        dumpstate -q -d -z -o $BUGREPORT_PATH/bugreport
        #move bugreport files to /data/media/0/ASUS/LogUploader/general/sdcard
        for filename in $BUGREPORT_PATH/*; do
            name=${filename##*/}
            cp $filename $GENERAL_LOG/$name
            rm $filename
        done
        rm -r /asdf/ASDF/ASDF.*
}

save_modem_log() {
	mv /data/media/diag_logs/QXDM_logs $MODEM_LOG
	echo "mv /data/media/diag_logs/QXDM_logs $MODEM_LOG"
}

save_tcpdump_log() {
	if [ -d "/data/logcat_log" ]; then
		if [ ".$is_tcpdump_status" == ".running" ]; then
			stop tcpdump-warp
			mv /data/logcat_log/capture.pcap0 /data/logcat_log/capture.pcap0-1
			start tcpdump-warp
			for fname in /data/logcat_log/capture.pcap*
			do
				if [ -e $fname ]; then
					if [ ".$fname" != "./data/logcat_log/capture.pcap0" ]; then
						mv $fname $TCP_DUMP_LOG
					fi
				fi
			done
		else
			mv /data/logcat_log/capture.pcap* $TCP_DUMP_LOG
		fi
	fi
}

remove_folder() {
	# remove folder
	if [ -e $GENERAL_LOG ]; then
		rm -r $GENERAL_LOG
	fi

	if [ -e $MODEM_LOG ]; then
		rm -r $MODEM_LOG
	fi

	if [ -e $TCP_DUMP_LOG ]; then
		rm -r $TCP_DUMP_LOG
	fi

	if [ -e $DUMPSYS_DIR ]; then
		rm -r $DUMPSYS_DIR
	fi
}

create_folder() {
	# create folder
	mkdir -p $GENERAL_LOG
	echo "mkdir -p $GENERAL_LOG"

	mkdir -p $MODEM_LOG
	echo "mkdir -p $MODEM_LOG"

	mkdir -p $TCP_DUMP_LOG
	echo "mkdir -p $GENERAL_LOG"
}

if [ ".$savelogs_prop" == ".0" ]; then
	remove_folder
        setprop persist.asus.uts com.asus.removelogs.completed
        setprop persist.asus.savelogs.complete 1
        setprop persist.asus.savelogs.complete 0
elif [ ".$savelogs_prop" == ".1" ]; then
	# check mount file
	umask 0;
	sync
	############################################################################################
	# remove folder
	remove_folder

	# create folder
	create_folder

	# save_general_log
	save_general_log

	############################################################################################
	# sync data to disk
	# 1015 sdcard_rw
	chmod -R 777 $LOG_PATH
	sync
        setprop persist.asus.uts com.asus.savelogs.completed

	echo "Done"
elif [ ".$savelogs_prop" == ".4" ]; then
	# check mount file
	umask 0;
	sync
	############################################################################################
	# remove folder
	remove_folder

	# create folder
	create_folder
	
	# save_general_log
	save_general_log
	
	# save_modem_log
	save_modem_log
	
	# save_tcpdump_log
	save_tcpdump_log
	
	############################################################################################
	# sync data to disk 
	# 1015 sdcard_rw
	chmod -R 777 $LOG_PATH
        setprop persist.asus.uts com.asus.savelogs.completed
fi
