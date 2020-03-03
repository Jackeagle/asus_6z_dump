#!/system/bin/sh
panic=`grep -c androidboot.bootreason=kernel_panic /proc/cmdline`
watchdog=`grep -c androidboot.bootreason=watchdog /proc/cmdline`
warmreset=`grep -c androidboot.bootreason=warm-reset /proc/cmdline`
powerkey=`grep -c androidboot.bootreason=power-key-restart /proc/cmdline`
abnormal=`grep -c androidboot.bootreason=abnormal /proc/cmdline`
unknown=`grep -c androidboot.bootreason=unknown /proc/cmdline`
pstore=`ls /sys/fs/pstore/`

max_log=20
log_head='ASDF'
log_root='/asdf/ASDF'
log_dir="$log_root/ASDF"
log_old="$log_root.old/ASDF"

asdf_already_capture=`getprop sys.asdf_completed`
asdf_completed=0

function copyLogs() {

    if [ "$asdf_already_capture" == "1" ]; then
        exit
    fi

    echo "ASDF: backup" > /proc/asusevtlog
    echo "ASDF: abnormal shutdown" > /proc/asusevtlog
    
    #Generate LastShutdown log
    uptime=`cat /proc/uptime | cut -d' ' -f1`
    ASDF_logs="/asdf/LastShutdown_${uptime}_`date +%Y%m%d-%H%M%S`.txt"
    for f in $pstore; do
        echo "--------- beginning of $f" >> $ASDF_logs
        cat /sys/fs/pstore/$f >> $ASDF_logs
    done

	#ASDF rotation
	if [ -e $log_dir.1 ]; then
		echo "$log_head: Start rotating log_dir!" > $action_log
		mv $log_root $log_root.old
		mkdir $log_root
		sync
		i=$(($max_log-1))
		while [ $i -gt 0 ]; do
			if [ -e $log_old.$i ]; then
				echo "$log_head: mv $log_old.$i $log_dir.$(($i+1))" > /proc/asusevtlog
				mv $log_old.$i $log_dir.$(($i+1))
			fi
			i=$(($i-1))
		done
		rm -r $log_root.old
	fi

	#create new ASDF
	echo "$log_head: Creating new log_dir" > $action_log
	mkdir $log_dir.1

	#backup ASDF
	echo "$log_head: Backup log files...." > $action_log
    
    fcount=0
    cd /asdf
	for fname in LastShutdown*
	do
		if [ -e $fname ]; then
			#echo "$log_head: $PWD/$fname found!" > $action_log
			echo "$log_head: $PWD/$fname found!"
			#cat $fname > $log_dir.1/${fname%${fname:(-4)}}_$fext && rm $fname
			mv $fname $log_dir.1/
			fcount=$(($fcount+1))
		fi
	done
	
	setprop sys.asdf_completed 1
	asdf_completed=1
}

if [ ".$android_reboot" == "." ]; then
	if [ -e $log_root ]; then
		echo "$log_head: found log_root=$log_root" > $action_log
	else
		echo "$log_head: creating log_root=$log_root" > $action_log
		echo "mkdir /asdf/ASDF" > /proc/asusevtlog
		mkdir $log_root
	fi
fi


if [ "$panic" == "1" ] || [ "$watchdog" == "1" ] || [ "$powerkey" == "1" ] || [ "$abnormal" == "1" ]; then
    copyLogs
elif [ "$warmreset" == "1" ] || [ "$unknown" == "1"  ]; then
    for f in $pstore; do
        isLongPressPower=`grep -c qpnp_kpdpwr_bark_irq /sys/fs/pstore/$f`
        if [ $isLongPressPower -ge 1 ]; then
            copyLogs
            break;
        fi
    done
fi

# reboot
if [ "$panic" == "1" ] || [ "$watchdog" == "1" ] || [ "$powerkey" == "1" ] || [ "$abnormal" == "1" ] || [ "$warmreset" == "1" ] || [ "$unknown" == "1" ];then
	if [ "$asdf_completed" == "1" ]; then
		sync
		sleep 3
		echo "[Reboot]: asdf reset" > /proc/asusevtlog
		reboot hardreset
	fi
fi
