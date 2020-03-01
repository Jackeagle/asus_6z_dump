#!/system/bin/sh
uts=`getprop persist.asus.uts`
is_savelogmtp_status=`getprop init.svc.savelogmtp`
is_savelogs_status=`getprop init.svc.savelogs`

if [ ".$is_savelogmtp_status" == ".running" ]; then
	am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///storage/emulated/0/
else
	if [ ".$is_savelogs_status" == ".running" ]; then
		am broadcast -a $uts
	fi
fi
