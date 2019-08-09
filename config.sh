#Chenzyadb magisk installer V2.0
#Copyright © Chenzyadb 2019 All Rights Reserved.
POSTFSDATA=true
# 自动挂载
AUTOMOUNT=true
#修改build.prop
PROPFILE=false
#执行 late_start
LATESTARTSERVICE=true
#显示安装信息
print_modname() {
  ui_print "************************************"
  ui_print "FastTurbo Boost Installer"
  ui_print "Author:Chenzyadb@coolapk"
  ui_print "***********************************"
}
#移动文件
REPLACE="
/system/priv-app/FastTurbo/base.apk
"
#设置权限
set_permissions() {
$MAGISK && set_perm_recursive $MODPATH 0 0 0777 0644 
set_perm  $MODPATH/service.sh  0  0  0777
set_perm  $MODPATH/system/priv-app/FastTurbo/base.apk 0 0 7777
set_perm  $MODPATH/system/bin/thermal-engine 0 0 0755
set_perm  $MODPATH/vendor/bin/thermal-engine 0 0 0755
}
Path=/data
if [ ! -d $Path/FastTurbo ]; then 
 mkdir -p $Path/FastTurbo
fi;
mode=$Path/FastTurbo/mode
#判断模块配置文件是否存在
if [ -e /data/FastTurbo/kmode ] ; then
chmod 0666 /data/FastTurbo/kmode
else
echo "auto" > /data/FastTurbo/kmode
fi
if [ -e /data/FastTurbo/temp_fix ] ; then
chmod 0666 /data/FastTurbo/temp_fix
else
echo "true" > /data/FastTurbo/temp_fix
fi
if [ -e /data/FastTurbo/net_fix ] ; then
chmod 0666 /data/FastTurbo/net_fix
else
echo "true" > /data/FastTurbo/net_fix
fi
if [ -e /data/FastTurbo/kernel_fix ] ; then
chmod 0666 /data/FastTurbo/kernel_fix
else
echo "true" > /data/FastTurbo/kernel_fix
fi
if [ -e /data/FastTurbo/google_fix ] ; then
chmod 0666 /data/FastTurbo/google_fix
else
echo "true" > /data/FastTurbo/google_fix
fi
if [ -e /data/FastTurbo/prop_fix ] ; then
chmod 0666 /data/FastTurbo/prop_fix
else
echo "true" > /data/FastTurbo/prop_fix
fi
if [ -e /data/FastTurbo/touch_fix ] ; then
chmod 0666 /data/FastTurbo/touch_fix
else
echo "true" > /data/FastTurbo/touch_fix
fi
if [ -e /data/FastTurbo/vm_fix ] ; then
chmod 0666 /data/FastTurbo/vm_fix
else
echo "true" > /data/FastTurbo/vm_fix
fi
if [ -e /data/FastTurbo/io_fix ] ; then
chmod 0666 /data/FastTurbo/io_fix
else
echo "true" > /data/FastTurbo/io_fix
fi
if [ -e /data/FastTurbo/lpl_fix ] ; then
chmod 0666 /data/FastTurbo/lpl_fix
else
echo "true" > /data/FastTurbo/lpl_fix
fi
if [ -e /data/FastTurbo/dse_fix ] ; then
chmod 0666 /data/FastTurbo/dse_fix
else
echo "true" > /data/FastTurbo/dse_fix
fi
turbo(){
echo "turbo" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "256" > /data/FastTurbo/zmode
echo "mid" > /data/FastTurbo/amode
fi
}
balance(){
echo "balance" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "512" > /data/FastTurbo/zmode
echo "low" > /data/FastTurbo/amode
fi
}
gamexe(){
echo "gamexe" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "off" > /data/FastTurbo/zmode
echo "max" > /data/FastTurbo/amode
fi
}
powersave(){
echo "powersave" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "1024" > /data/FastTurbo/zmode
echo "off" > /data/FastTurbo/amode
fi
}
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK
keytest() {
  ui_print " - 音量键测试 -"
  ui_print "   按下 [音量+] 键:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    abort "   未检测到音量键!"
  fi
}

go_replace(){
if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "** 音量按钮编程中 **"
    ui_print " "
    ui_print "** 再次按下音量+ **"
    $FUNCTION "UP"
    ui_print "** 按下音量- **"
    $FUNCTION "DOWN"
  fi
  ui_print "模式1：均衡模式(balance)"
  ui_print "模式2:  性能模式(turbo)"
  ui_print "模式3：Game X Extreme模式 (gamexe)"
  ui_print "模式4：超级省电模式(powersave)"
  ui_print "** 请选择调度模式 **"
  ui_print " "
  ui_print "  音量(+) = 均衡模式(balance)"
  ui_print "  音量(-) = 跳过 & 更多模式..."
  ui_print " "

  if $FUNCTION; then
    balance
    ui_print "   已选择均衡模式."
    ui_print " "

  else
  ui_print "** 请选择调度模式 **"
  ui_print " "
  ui_print "   音量(+) = 性能模式(turbo)"
  ui_print "   音量(-) = 跳过 & 更多模式. .."
  ui_print " "

  if $FUNCTION; then
    turbo
    ui_print "   已选择性能模式."
    ui_print " "

  else

  ui_print "** 请选择调度模式 **"
  ui_print " "
  ui_print "   音量(+) = Game X Extreme 模式(gamexe)"
  ui_print "   音量(-) = 跳过 & 更多模式 .."
  ui_print " "

  if $FUNCTION; then
    gamexe
    ui_print "   已选择Game X Extreme模式."
    ui_print " "

  else

  ui_print "** 请选择调度模式 **"
  ui_print " "
  ui_print "   音量(+) = 超级省电(powersave)"
  ui_print " "

  if $FUNCTION; then
    powersave
    ui_print "   已选择超级省电模式."
    ui_print " "

  else
    balance
    ui_print "  错误输入."
    ui_print "  默认选择均衡模式."
    ui_print " "
  fi
  fi
  fi
  fi
ui_print "- 正在屏蔽温控"
  mkdir -p ${MODPATH}/system/etc
  mkdir -p ${MODPATH}/system/vendor/etc
  for tconf in $(ls /system/etc/thermal-engine*.conf /system/vendor/etc/thermal-engine*.conf)
  do
    touch ${MODPATH}${tconf}
  done
  mkdir ${MODPATH}/system/bin
  mkdir ${MODPATH}/system/vendor/bin
  mkdir ${MODPATH}/system/vendor/lib
  mkdir ${MODPATH}/system/vendor/lib64
  touch $MODPATH/system/bin/thermal-engine
  touch $MODPATH/system/vendor/bin/thermal-engine
  touch $MODPATH/system/vendor/lib/libthermalioctl.so
  touch $MODPATH/system/vendor/lib/libthermalclient.so
  touch $MODPATH/system/vendor/lib64/libthermalioctl.so
  touch $MODPATH/system/vendor/lib64/libthermalclient.so
ui_print "- 温控已屏蔽"
  }


