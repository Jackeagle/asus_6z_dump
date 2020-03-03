#!/system/bin/sh

setprop sys.asus.setenforce 1
echo "[UpdateAttKey] setenforce: permissive" > /proc/asusevtlog
sleep 2
KmInstallKeybox /vendor/factory/key.xml auto true > /vendor/factory/AsusUpdateAttKey.log 2>&1
setprop sys.asus.setenforce 0
echo "[UpdateAttKey] setenforce: enforcing" > /proc/asusevtlog
