#!/system/bin/sh
#------------------------------------------------------
#FastTurbo Boost 
#Author:@Chenzyadb (xda,coolapk,bilibili)
#Opensource Licence : modpath/license.txt
#Copyright © Chenzyadb 2019 All Rights Reserved.
#------------------------------------------------------
#修改关键配置文件权限
chmod 7777 /system/priv-app/FastTurbo/base.apk 
chmod 0777 /system/bin/FastTurbo
chmod 0777 /system/lib/krnln.so
chmod 0666 /data/FastTurbo/FastTurbo.log
chmod 0666 /data/FastTurbo/mode
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
chmod 0666 /data/FastTurbo/kmode
chmod 0666 /data/FastTurbo/temp_fix
chmod 0666 /data/FastTurbo/net_fix
chmod 0666 /data/FastTurbo/kernel_fix
chmod 0666 /data/FastTurbo/google_fix
chmod 0666 /data/FastTurbo/prop_fix
chmod 0666 /data/FastTurbo/touch_fix
chmod 0666 /data/FastTurbo/vm_fix
chmod 0666 /data/FastTurbo/io_fix
chmod 0666 /data/FastTurbo/lpl_fix
chmod 0666 /data/FastTurbo/dse_fix
Path=/data
if [ ! -d $Path/FastTurbo ]; then 
 mkdir -p $Path/FastTurbo
fi;
ft=$Path/FastTurbo
LOG=/$ft/FastTurbo.log
#FastTurbo Function
function write() {    #修改内核参数
    echo -n $2 > $1
}
function chwrite() {   #修改内核参数（高级）
	if [ -f $2 ]; then
		chmod 0644 $2
		echo $1 > $2
		chmod 0444 $2
	fi
}
#得到SOC型号
SOC=""
SOC=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'`
if  [ $SOC = "" ] ; then
SOC=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'`
fi
case $SOC in msm*)
qualcomm_soc="true"
esac
case $SOC in sdm*)
qualcomm_soc="true"
esac
#得到GPU信息
if [ -e /sys/class/kgsl/kgsl-3d0/devfreq/governor ] ; then
GPU_DIR=/sys/class/kgsl/kgsl-3d0/
GPU_SUB="adreno"
elif [ -e /sys/devices/soc.0/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq/governor ] ; then
GPU_DIR=/sys/devices/soc.0/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/
GPU_SUB="adreno"
elif [ -d /sys/devices/e8600000.mali/ ] ; then
GPU_DIR=/sys/devices/e8600000.mali/
GPU_SUB="mali"
elif [ -d "/sys/devices/*.mali" ]; then
GPU_DIR="/sys/devices/*.mali"
GPU_SUB="mali"
elif [ -d "/sys/devices/*.gpu" ]; then
GPU_DIR="/sys/devices/*.gpu"
GPU_SUB="mali"
elif [ -d "/sys/devices/platform/mali.0" ]; then
GPU_DIR="/sys/devices/platform/mali.0"
GPU_SUB="mali"
elif [ -d "/sys/devices/platform/mali-*.0" ]; then
GPU_DIR="/sys/devices/platform/mali-*.0"
GPU_SUB="mali"
elif [ -d "/sys/module/mali/parameters" ]; then
GPU_DIR="/sys/module/mali/parameters"
GPU_SUB="mali"
elif [ -d "/sys/class/misc/mali0" ]; then
GPU_DIR="/sys/class/misc/mali0"
GPU_SUB="mali"
fi
if [ -e $GPU_DIR/devfreq/governor ] ; then
GPU_MIN=`cat $GPU_DIR/devfreq/min_freq`
GPU_MAX=`cat $GPU_DIR/devfreq/max_freq`
else 
GPU_MIN=`cat $GPU_DIR/devfreq/gpufreq/min_freq`
GPU_MAX=`cat $GPU_DIR/devfreq/gpufreq/max_freq`
fi
#得到CPU信息
core_num=`cat /sys/devices/system/cpu/kernel_max`
min_core_num_1=$(cat /sys/devices/system/cpu/cpu0/core_ctl/min_cpus)
min_core_num_2=$(cat /sys/devices/system/cpu/cpu4/core_ctl/min_cpus)
freq0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
freq1=$(cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq)
freq2=$(cat /sys/devices/system/cpu/cpu2/cpufreq/cpuinfo_max_freq)
freq3=$(cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq)
freq4=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq)
freq5=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq)
freq6=$(cat /sys/devices/system/cpu/cpu6/cpufreq/cpuinfo_max_freq)
freq7=$(cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq)
freq8=$(cat /sys/devices/system/cpu/cpu8/cpufreq/cpuinfo_max_freq)
freq9=$(cat /sys/devices/system/cpu/cpu9/cpufreq/cpuinfo_max_freq)
if [ $core_num = "7" ] ; then
if [ ${min_core_num_1} -lt 4 ] ; then
freq1=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
freq2=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
freq3=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
fi
if [ ${min_core_num_2} -lt 4 ] ; then
freq5=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq)
freq6=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq)
freq7=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq)
fi
fi
#得到RAM信息
ram_value=$(free | grep Mem | awk '{print $2}')
#得到模块配置参数
mode="turbo"
mode=`cat /data/FastTurbo/mode`
ZR=`cat /data/FastTurbo/zmode`
adreno_mode=`cat /data/FastTurbo/amode`
k_mode=`cat /data/FastTurbo/kmode`
temp_fix=`cat /data/FastTurbo/temp_fix`
net_fix=`cat /data/FastTurbo/net_fix`
kernel_fix=`cat /data/FastTurbo/kernel_fix`
google_fix=`cat /data/FastTurbo/google_fix`
prop_fix=`cat /data/FastTurbo/prop_fix`
touch_fix=`cat /data/FastTurbo/touch_fix`
vm_fix=`cat /data/FastTurbo/vm_fix`
io_fix=`cat /data/FastTurbo/io_fix`
lpl_fix=`cat /data/FastTurbo/lpl_fix`
dse_fix=`cat /data/FastTurbo/dse_fix`
#得到手机信息
tinfo=$(date +"%d-%m-%Y %r")
API=`getprop ro.build.version.sdk | tr '[:upper:]' '[:lower:]'`
aver=`getprop ro.build.version.release | tr '[:upper:]' '[:lower:]'`
vendor=`getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]'`
id=`getprop ro.product.model | tr '[:upper:]' '[:lower:]'`
ROM=$(getprop ro.build.display.id) 2>/dev/null
KERNEL=$(uname -r) 2>/dev/null
#手机和模块信息显示
echo "时间：$tinfo " > /data/FastTurbo/FastTurbo.log
echo "=========================" |  tee -a $LOG;
echo "* SOC型号：$SOC" |  tee -a $LOG;
echo "* Android Verson: $aver" |  tee -a $LOG;
echo "* Android API: $API" |  tee -a $LOG;
echo "* 制造商：$vendor" |  tee -a $LOG;
echo "* 手机型号：$id" |  tee -a $LOG;
echo "* ROM：$ROM" |  tee -a $LOG;
echo "* 内核: $KERNEL" |  tee -a $LOG;
echo "* 核心频率获取完毕，频率列表如下：" |  tee -a $LOG;
echo "* ${freq0} ${freq1} ${freq2} ${freq3}" |  tee -a $LOG;
echo "* ${freq4} ${freq5} ${freq6} ${freq7}" |  tee -a $LOG;
if [ $core_num = "9" ] ; then
echo "* ${freq8} ${freq9}" |  tee -a $LOG;
fi
echo "* 内存大小：$ram_value" |  tee -a $LOG;
if [ $GPU_SUB = "adreno" ] ; then
echo "* GPU供应商：Qualcomm Adreno" |  tee -a $LOG;
else
echo "* GPU供应商：ARM Mali" |  tee -a $LOG;
fi
echo "* GPU频率：$GPU_MAX" |  tee -a $LOG;
echo "* FastTurbo处于$mode模式" |  tee -a $LOG;
echo "=========================" |  tee -a $LOG;
#====================SmartCore====================
#-gt是大于
#-lt是小于
#-eq是等于
#-ne是不等于
#-ge是大于等于
echo "* FastTurbo SmartCore 初始化..." |  tee -a $LOG;
soc_type="" #SOC类型
if [ $core_num = "7" ] ; then
if [ ${freq0} -eq ${freq7} ] ; then
 if [ ${freq0} -gt 1700000 ] ; then
  soc_type="mid"
 else
  soc_type="low"
 fi
elif [ ${freq4} -eq ${freq7} ] ; then
 if [ ${freq0} -gt ${freq7} ] ; then
  if [ ${freq0} -gt 1950000 ] ; then
   soc_type="high"
  elif [ ${freq0} -gt 1600000 ] ; then
   soc_type="mid"  
  else
   soc_type="low"
  fi
 else
  if [ ${freq7} -gt 1950000 ] ; then
   soc_type="high" 
  elif [ ${freq7} -gt 1600000 ] ; then
   soc_type="mid"  
  else
   soc_type="low"
  fi
 fi
elif [ ${freq2} -eq ${freq7} ] ; then
  if [ ${freq0} -eq ${freq1} ] ; then
   soc_type="high"
  fi
elif [ ${freq0} -eq ${freq5} ] ; then
  if [ ${freq6} -eq ${freq7} ] ; then
   soc_type="high"
  fi
fi
elif [ $core_num = "5" ] ; then
soc_type="mid"
elif [ $core_num = "3" ] ; then
 if [ ${freq0} -gt 1800000 ] ; then
 soc_type="mid"
 else
 soc_type="low"
 fi
fi
if [ $soc_type = "" ] ; then
echo "* FastTurbo SmartCore 初始化失败." |  tee -a $LOG;
soc_type="mid"
else
echo "* FastTurbo SmartCore 初始化成功！" |  tee -a $LOG;
if [ $soc_type = "high" ] ; then
 echo "* 检测到高端SOC." |  tee -a $LOG;
elif [ $soc_type = "mid" ] ; then
 echo "* 检测到中端SOC." |  tee -a $LOG;
elif [ $soc_type = "low" ] ; then
 echo "* 检测到低端SOC." |  tee -a $LOG;
fi
fi
#=================================================
if [ -e /system/bin/lkt ] ; then
echo "* 检测到您已安装LKT模块，可能会与FastTurbo冲突." |  tee -a $LOG;
echo "* 这条信息仅为提示作用，FastTurbo仍然会执行优化." |  tee -a $LOG;
fi
if [ $core_num = "1" ] ; then
echo "* FastTurbo 不支持双核处理器优化! " |  tee -a $LOG;
exit 0 
fi
#干掉热插拔
# Performance daemon
stop "perfd"
# Thermal daemon
stop "thermald"
# mpdecision
stop "mpdecision"
stop "thermal-engine"
# perflock HAL
stop "perf-hal-1-0"
if [ -e /data/system/perfd/default_values ]; then
rm /data/system/perfd/default_values
fi
if [ $qualcomm_soc = "true" ] ; then
#区分高通和其他soc
chwrite 0 /sys/module/msm_thermal/core_control/enabled
chwrite 0 /sys/module/msm_thermal/parameters/enabled
else
chwrite 0 /proc/hps/enable
chwrite 0 /sys/power/cpuhotplug/enabled
chwrite 0 /sys/devices/system/cpu/cpuhotplug/enabled
fi
echo "* 温控屏蔽完毕" |  tee -a $LOG;
#关闭原有CPU boost
if [ -e /sys/module/msm_performance/parameters/touchboost ]; then
 chmod 0644 /sys/module/msm_performance/parameters/touchboost
 echo "0" > /sys/module/msm_performance/parameters/touchboost 
fi
if [ -e /sys/module/cpu_boost/parameters/boost_ms ]; then
 chmod 0644 /sys/module/cpu_boost/parameters/boost_ms
 echo "0" > /sys/module/cpu_boost/parameters/boost_ms
fi
if [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
 chmod 0644 /sys/module/cpu_boost/parameters/sched_boost_on_input
 echo "N" > /sys/module/cpu_boost/parameters/sched_boost_on_input
fi
if [ -e /sys/power/pnpmgr/touch_boost ]; then
 chmod 0644 /sys/power/pnpmgr/touch_boost 
 echo "0" > /sys/power/pnpmgr/touch_boost 
fi
#调整快充温控阈值
if [ $temp_fix = "true" ] ; then
if [ -e /sys/class/power_supply/bms/temp_warm ] ; then
chwrite 450 /sys/class/power_supply/bms/temp_warm
echo "* 快充温度阀值已自动调整" |  tee -a $LOG;
fi
fi
if [ $mode = "powersave" ] ; then
if [ -e /sys/devices/system/cpu/cpu4/core_ctl/min_cpus ] ; then
if [ $core_num = "7" ] ; then
chwrite 2 /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
chwrite 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chwrite 2 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
chwrite 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
elif [ $core_num = "5" ] ; then
chwrite 2 /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
chwrite 1 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chwrite 2 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
chwrite 1 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
fi
fi
else
if [ -e /sys/devices/system/cpu/cpu4/core_ctl/min_cpus ] ; then
if [ $core_num = "7" ] ; then
chwrite 4 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
chwrite 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
chwrite 4 /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
chwrite 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
elif [ $core_num = "5" ] ; then
chwrite 4 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
chwrite 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
chwrite 4 /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
chwrite 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
fi
fi
if [ -e /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres ] ; then
chwrite 0 /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
chwrite 0 /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
fi
fi
#powersave模式下关闭核心以省电
if [ -e /sys/devices/system/cpu/cpu1/online ] ; then
if [ $mode = "powersave" ] ; then
if [ $core_num = "9" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 0 /sys/devices/system/cpu/cpu2/online
chwrite 0 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 0 /sys/devices/system/cpu/cpu6/online
chwrite 0 /sys/devices/system/cpu/cpu7/online
chwrite 1 /sys/devices/system/cpu/cpu8/online
chwrite 0 /sys/devices/system/cpu/cpu9/online
elif [ $core_num = "7" ] ; then
chwrite 0 /sys/devices/system/cpu/cpu0/online
chwrite 0 /sys/devices/system/cpu/cpu1/online
chwrite 0 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 1 /sys/devices/system/cpu/cpu6/online
chwrite 0 /sys/devices/system/cpu/cpu7/online
elif [ $core_num = "5" ] ; then
chwrite 0 /sys/devices/system/cpu/cpu0/online
chwrite 0 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 0 /sys/devices/system/cpu/cpu5/online
elif [ $core_num = "3" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 0 /sys/devices/system/cpu/cpu3/online
fi
else
#将所有核心启动
if [ $core_num = "9" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 1 /sys/devices/system/cpu/cpu6/online
chwrite 1 /sys/devices/system/cpu/cpu7/online
chwrite 1 /sys/devices/system/cpu/cpu8/online
chwrite 1 /sys/devices/system/cpu/cpu9/online
elif [ $core_num = "7" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 1 /sys/devices/system/cpu/cpu6/online
chwrite 1 /sys/devices/system/cpu/cpu7/online
elif [ $core_num = "5" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
elif [ $core_num = "3" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu0/online
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
fi
fi
fi
#禁用温控(内核级）
if [ -d /sys/class/thermal/ ] ; then
chwrite "disabled" /sys/class/thermal/thermal_zone0/mode
chwrite "disabled" /sys/class/thermal/thermal_zone1/mode
chwrite "disabled" /sys/class/thermal/thermal_zone2/mode
chwrite "disabled" /sys/class/thermal/thermal_zone3/mode
chwrite "disabled" /sys/class/thermal/thermal_zone4/mode
chwrite "disabled" /sys/class/thermal/thermal_zone5/mode
chwrite "disabled" /sys/class/thermal/thermal_zone6/mode
chwrite "disabled" /sys/class/thermal/thermal_zone7/mode
chwrite "disabled" /sys/class/thermal/thermal_zone8/mode
chwrite "disabled" /sys/class/thermal/thermal_zone9/mode
fi
echo "* CPU核心控制启动完毕" |  tee -a $LOG;
#修改build.prop以保证系统高效运行
if [ $prop_fix = "true" ] ; then
if [ $mode = "turbo" ] ; then
setprop MIN_HIDDEN_APPS false
setprop ACTIVITY_INACTIVE_RESET_TIME false
setprop MIN_RECENT_TASKS false
setprop PROC_START_TIMEOUT false
setprop CPU_MIN_CHECK_DURATION false
setprop GC_TIMEOUT false
setprop SERVICE_TIMEOUT false
setprop MIN_CRASH_INTERVAL false
setprop ENFORCE_PROCESS_LIMIT false
setprop persist.sys.NV_FPSLIMIT 90
setprop persist.sys.NV_POWERMODE 1
setprop persist.sys.NV_PROFVER 15
setprop persist.sys.NV_STEREOCTRL 0
setprop persist.sys.NV_STEREOSEPCHG 0
setprop persist.sys.NV_STEREOSEP 20
setprop persist.sys.use_16bpp_alpha 1
setprop debug.egl.swapinterval -60
echo "* turbo模式下build.prop优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
setprop ENFORCE_PROCESS_LIMIT false
echo "* balance模式下build.prop优化完毕" |  tee -a $LOG;
elif [ $mode = "gamexe" ] ; then
setprop MIN_HIDDEN_APPS false
setprop ACTIVITY_INACTIVE_RESET_TIME false
setprop MIN_RECENT_TASKS false
setprop PROC_START_TIMEOUT false
setprop CPU_MIN_CHECK_DURATION false
setprop GC_TIMEOUT false
setprop SERVICE_TIMEOUT false
setprop MIN_CRASH_INTERVAL false
setprop ENFORCE_PROCESS_LIMIT false
setprop persist.sys.NV_FPSLIMIT 90
setprop persist.sys.NV_POWERMODE 1
setprop persist.sys.NV_PROFVER 15
setprop persist.sys.NV_STEREOCTRL 0
setprop persist.sys.NV_STEREOSEPCHG 0
setprop persist.sys.NV_STEREOSEP 20
setprop persist.sys.use_16bpp_alpha 1
setprop debug.egl.swapinterval -60
echo "* gamexe模式下build.prop优化完毕" |  tee -a $LOG;
else
echo "* powersave模式下build.prop优化完毕" |  tee -a $LOG;
fi
fi
#wakelocks优化
if [ -e /sys/module/bcmdhd/parameters/wlrx_divide ]; then
 echo "4" > /sys/module/bcmdhd/parameters/wlrx_divide 2>/dev/null
 echo "4" > /sys/module/bcmdhd/parameters/wlctrl_divide 2>/dev/null
 echo "* Wlan Wakelocks 优化完毕" |  tee -a $LOG;
fi;
if [ -e /sys/module/wakeup/parameters/enable_bluetooth_timer ]; then
 echo "Y" > /sys/module/wakeup/parameters/enable_bluetooth_timer 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_ipa_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_netlink_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_netmgr_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws 2>/dev/null
 echo "Y" > /sys/module/wakeup/parameters/enable_timerfd_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_netmgr_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_ipa_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws 2>/dev/null
 echo "N" > /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws 2>/dev/null
 echo "* Wakelocks 优化完毕" |  tee -a $LOG;
fi;
if [ -e /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
 echo "IPA_WS;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;bam_dmux_wakelock;" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
 echo "* Boeffla_Wakelock_Blocker 优化完毕" |  tee -a $LOG;
fi;
#优化网络连接
if [ $net_fix = "true" ] ; then
sysctl -e -w net.ipv4.tcp_timestamps=0
sysctl -e -w net.ipv4.tcp_sack=1
sysctl -e -w net.ipv4.tcp_fack=1
sysctl -e -w net.ipv4.tcp_window_scaling=1
echo "* 网络连接优化完毕" | tee -a $LOG;
fi
#修改内核配置以保证内核高效运行
if [ $kernel_fix = "true" ] ; then
if [ -e /proc/sys/vm/page-cluster ] ; then
chwrite “8″ /proc/sys/vm/page-cluster
chwrite “64000″ /proc/sys/kernel/msgmni
chwrite “64000″ /proc/sys/kernel/msgmax
chwrite “10″ /proc/sys/fs/lease-break-time
chwrite “500,512000,64,2048″ /proc/sys/kernel/sem
fi
if [ -e /sys/kernel/debug/sched_features ]; then
 chwrite "NO_NORMALIZED_SLEEPER" /sys/kernel/debug/sched_features
 chwrite "GENTLE_FAIR_SLEEPERS" /sys/kernel/debug/sched_features
 chwrite "NO_NEW_FAIR_SLEEPERS" /sys/kernel/debug/sched_features
 chwrite "WAKEUP_PREEMPT" /sys/kernel/debug/sched_features
 chwrite "NO_AFFINE_WAKEUPS" /sys/kernel/debug/sched_features
fi;
if [ -e /sys/kernel/sched/gentle_fair_sleepers ]; then
 chwrite "0" /sys/kernel/sched/gentle_fair_sleepers
fi;
echo "* 系统内核优化完毕" |  tee -a $LOG;
fi
#优化Google套件
if [ $google_fix = "true" ] ; then
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
echo "* Google 套件优化完毕" |  tee -a $LOG;
fi
#优化触控以提升游戏体验
if [ $touch_fix = "true" ] ; then
if [ -e /sys/kernel/fp_boost/enabled ] ; then
chwrite "1" /sys/kernel/fp_boost/enabled 
echo "* 触控优化完毕" |  tee -a $LOG;
fi
fi
#GPU优化部分
if [ $GPU_SUB = "adreno" ] ; then
GPU_PWR=$(cat $GPU_DIR/num_pwrlevels) 2>/dev/null
GPU_PWR=$(($GPU_PWR-1))
GPU_TURBO=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)+0.5)}')
GPU_TURBO=$(round ${GPU_TURBO} 0)
if [ -e $GPU_DIR/devfreq/governor ] ; then
#Qualcomm GPU
if [ $mode = "gamexe" ] ; then
chwrite "simple_ondemand" $GPU_DIR/devfreq/governor
elif [ $mode = "powersave" ] ; then
chwrite "msm-adreno-tz" $GPU_DIR/devfreq/governor
elif [ $mode = "turbo" ] ; then
chwrite "simple_ondemand" $GPU_DIR/devfreq/governor
elif [ $mode = "balance" ] ; then
chwrite "msm-adreno-tz" $GPU_DIR/devfreq/governor
fi
fi
fi
if [ $GPU_SUB = "mali" ] ; then
if [ -e $GPU_DIR/devfreq/gpufreq/governor ] ; then
#Mali GPU
if [ $mode = "gamexe" ] ; then
chwrite "mali_ondemand" $GPU_DIR/devfreq/gpufreq/governor
elif [ $mode = "powersave" ] ; then
chwrite "pm_qos" $GPU_DIR/devfreq/gpufreq/governor
elif [ $mode = "turbo" ] ; then
chwrite "mali_ondemand" $GPU_DIR/devfreq/gpufreq/governor
elif [ $mode = "balance" ] ; then
chwrite "pm_qos" $GPU_DIR/devfreq/gpufreq/governor
fi
fi
fi
if [ $GPU_SUB = "adreno" ] ; then
#Qualcomm
if [ $mode = "gamexe" ] ; then
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MAX "$GPU_DIR/devfreq/target_freq" 
chwrite $GPU_MAX "$GPU_DIR/devfreq/cur_freq"
chwrite 0 "$GPU_DIR/max_pwrlevel"
chwrite $GPU_TURBO "$GPU_DIR/min_pwrlevel"
chwrite 1 "$GPU_DIR/force_no_nap"
chwrite 0 "$GPU_DIR/bus_split"
chwrite 1 "$GPU_DIR/force_bus_on"
chwrite 1 "$GPU_DIR/force_clk_on"
chwrite 1 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
elif [ $mode = "turbo" ] ; then
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MAX "$GPU_DIR/devfreq/target_freq" 
chwrite $GPU_MAX "$GPU_DIR/devfreq/cur_freq"
chwrite 0 "$GPU_DIR/max_pwrlevel"
chwrite $GPU_TURBO "$GPU_DIR/min_pwrlevel"
chwrite 1 "$GPU_DIR/force_no_nap"
chwrite 0 "$GPU_DIR/bus_split"
chwrite 1 "$GPU_DIR/force_bus_on"
chwrite 1 "$GPU_DIR/force_clk_on"
chwrite 1 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
elif [ $mode = "balance" ] ; then
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/target_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/cur_freq"
chwrite 0 "$GPU_DIR/throttling"
chwrite 0 "$GPU_DIR/force_no_nap"
chwrite 1 "$GPU_DIR/bus_split"
chwrite 0 "$GPU_DIR/force_bus_on"
chwrite 0 "$GPU_DIR/force_clk_on"
chwrite 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
chwrite "6000" /sys/module/adreno_idler/parameters/adreno_idler_idleworkload 
chwrite '15' /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
chwrite '15' /sys/module/adreno_idler/parameters/adreno_idler_idlewait
else
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_idlewait ] ; then
chwrite "10000" /sys/module/adreno_idler/parameters/adreno_idler_idleworkload 
chwrite '40' /sys/module/adreno_idler/parameters/adreno_idler_downdifferential 
chwrite '24' /sys/module/adreno_idler/parameters/adreno_idler_idlewait 
echo "* Powersave模式下Adreno GPU空载怠速优化完毕" |  tee -a $LOG;
fi
fi
if [ $mode = "gamexe" ] ; then
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi
elif [ $mode = "turbo" ] ; then
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
elif [ $mode = "balance" ] ; then
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "1" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
else
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "1" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
fi
if [ -e /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ]; then 
 chwrite "1" /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
 chwrite "Y" /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
 echo "* GPU Algorithm 优化完毕" | tee -a $LOG;
fi;
echo "* $mode模式下Adreno GPU优化完毕" |  tee -a $LOG;
if [ -e $GPU_DIR/devfreq/adrenoboost ] ; then
if [ $adreno_mode = "max" ] ; then 
 echo "3" > $GPU_DIR/devfreq/adrenoboost
echo "* adreno加速max模式已启用" |  tee -a $LOG;
elif [ $adreno_mode = "mid" ] ; then
 echo "2" > $GPU_DIR/devfreq/adrenoboost
echo "* adreno加速mid模式已启用" |  tee -a $LOG;
elif [ $adreno_mode = "low" ] ; then
 echo "1" > $GPU_DIR/devfreq/adrenoboost
echo "* adreno加速low模式已启用" |  tee -a $LOG;
else 
 echo "0" > $GPU_DIR/devfreq/adrenoboost
echo "* adreno加速已禁用" |  tee -a $LOG;
fi
else
echo "error" > /data/FastTurbo/amode
echo "* 设备不支持adreno加速" |  tee -a $LOG;
fi
elif [ $GPU_SUB = "mali" ] ; then
#Mali GPU
echo "error" > /data/FastTurbo/amode
echo "* 设备不支持adreno加速" |  tee -a $LOG;
if [ -e $GPU_DIR/devfreq/gpufreq/mali_ondemand/vsync_upthreshold ] ; then
if [ $mode = "gamexe" ] ; then
chwrite 20 $GPU_DIR/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 10 $GPU_DIR/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
chwrite $GPU_MAX $GPU_DIR/devfreq/gpufreq/mali_ondemand/animation_boost_freq
echo "* gamexe 模式下Mali GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "turbo" ] ; then
chwrite 40 $GPU_DIR/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 20 $GPU_DIR/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
chwrite $GPU_MAX $GPU_DIR/devfreq/gpufreq/mali_ondemand/animation_boost_freq
echo "* turbo 模式下Mali GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
chwrite 50 $GPU_DIR/devfreq/gpufreq/pm_qos/vsync_upthreshold
chwrite 30 $GPU_DIR/devfreq/gpufreq/pm_qos/vsync_downdifferential
echo "* balance 模式下Mali GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "powersave" ] ; then
chwrite 80 $GPU_DIR/devfreq/gpufreq/pm_qos/vsync_upthreshold
chwrite 60 $GPU_DIR/devfreq/gpufreq/pm_qos/vsync_downdifferential
echo "* powersave 模式下Mali GPU优化完毕" |  tee -a $LOG;
fi
if [ -e /proc/mali/dvfs_enable ] ; then
chwrite "1" /proc/mali/dvfs_enable
fi
fi
else
echo "* 设备不支持GPU优化" |  tee -a $LOG;
fi
#CPU优化部分
if [ $mode = "turbo" ] ; then
GOV="interactive"
elif [ $mode = "balance" ] ; then
GOV="ondemand"
elif [ $mode = "gamexe" ] ; then
GOV="interactive"
elif [ $mode = "powersave" ] ; then
GOV="ondemand"
fi
ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
MB=/sys/devices/system/cpu/cpu5/cpufreq/$GOV
if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
ML=/sys/devices/system/cpu/cpufreq/$GOV
fi
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] ; then
if [ $core_num = "9" ] ; then
chwrite "$GOV" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu8/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu9/cpufreq/scaling_governor
elif [ $core_num = "7" ] ; then
chwrite "$GOV" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
elif [ $core_num = "5" ] ; then
chwrite "$GOV" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
elif [ $core_num = "3" ] ; then
chwrite "$GOV" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
chwrite "$GOV" /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
fi
fi
if [ $GOV = "interactive" ] ; then
 echo "0" > $ML/boost 2>/dev/null
 echo "0" > $ML/boostpulse 2>/dev/null
 echo "0" > $ML/boostpulse_duration 2>/dev/null
 echo "1" > $ML/fastlane 2>/dev/null
 echo "0" > $ML/align_windows 2>/dev/null
 echo "1" > $ML/use_migration_notif 2>/dev/null
 echo "1" > $ML/use_sched_load 2>/dev/null
 echo "0" > $ML/enable_prediction 2>/dev/null
 echo "1" > $ML/fast_ramp_down 2>/dev/null
 echo "99" > $ML/go_hispeed_load 2>/dev/null
 echo "10000" > $ML/timer_rate 2>/dev/null
 echo "0" > $ML/io_is_busy 2>/dev/null
 echo "40000" > $ML/min_sample_time 2>/dev/null
 echo "80000" > $ML/timer_slack 2>/dev/null
 echo "0" > $MB/boost 2>/dev/null
 echo "0" > $MB/boostpulse 2>/dev/null
 echo "0" > $MB/boostpulse_duration 2>/dev/null
 echo "1" > $MB/fastlane 2>/dev/null
 echo "0" > $MB/align_windows 2>/dev/null
 echo "1" > $MB/use_migration_notif 2>/dev/null
 echo "1" > $MB/use_sched_load 2>/dev/null
 echo "0" > $MB/enable_prediction 2>/dev/null
 echo "1" > $MB/fast_ramp_down 2>/dev/null
 echo "99" > $MB/go_hispeed_load 2>/dev/null
 echo "12000" > $MB/timer_rate 2>/dev/null
 echo "0" > $MB/io_is_busy 2>/dev/null
 echo "60000" > $MB/min_sample_time 2>/dev/null
 echo "80000" > $MB/timer_slack 2>/dev/null
 echo "* $mode模式下频率调整策略优化完毕" |  tee -a $LOG;
elif [ $GOV = "ondemand" ] ; then
 echo "90" > $MB/up_threshold 2>/dev/null
 echo "85" > $MB/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $MB/up_threshold_multi_core 2>/dev/null
 echo "75000" > $MB/sampling_rate 2>/dev/null
 echo "2" > $MB/sampling_down_factor 2>/dev/null
 echo "10" > $MB/down_differential 2>/dev/null
 echo "35" > $MB/freq_step 2>/dev/null
 echo "90" > $ML/up_threshold 2>/dev/null
 echo "85" > $ML/up_threshold_any_cpu_load 2>/dev/null
 echo "85" > $ML/up_threshold_multi_core 2>/dev/null
 echo "75000" > $ML/sampling_rate 2>/dev/null
 echo "2" > $ML/sampling_down_factor 2>/dev/null
 echo "10" > $ML/down_differential 2>/dev/null
 echo "35" > $ML/freq_step 2>/dev/null
 echo "* $mode模式下频率调整策略优化完毕" |  tee -a $LOG;
fi
if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ] ; then
if [ $mode = "turbo" ] ; then
#CPU加速调整
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "150" > /sys/module/cpu_input_boost/parameters/input_boost_duration
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "150" > /sys/module/cpu_boost/parameters/input_boost_ms
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "80" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "40" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "40" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "* turbo模式下CPU加速策略已调整" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "80" > /sys/module/cpu_input_boost/parameters/input_boost_duration
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "80" > /sys/module/cpu_boost/parameters/input_boost_ms
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "50" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "30" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "30" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "* balance模式下CPU加速策略已调整" |  tee -a $LOG;
elif [ $mode = "gamexe" ] ; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "150" > /sys/module/cpu_input_boost/parameters/input_boost_duration
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "150" > /sys/module/cpu_boost/parameters/input_boost_ms
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "80" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "40" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "40" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "* gamexe模式下CPU加速策略已调整" |  tee -a $LOG;
elif [ $mode = "powersave" ] ; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "60" > /sys/module/cpu_input_boost/parameters/input_boost_duration
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "60" > /sys/module/cpu_boost/parameters/input_boost_ms
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "40" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "20" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "20" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "* powersave模式下CPU加速策略已调整" |  tee -a $LOG;
fi
fi
if [ -e /proc/sys/kernel/hotplug ] ; then
chwrite 0 /proc/sys/kernel/hotplug
fi
if [ -e /proc/sys/kernel/sched_boost ] ; then
chwrite 1 /proc/sys/kernel/sched_boost
fi
#调整虚拟内存以保证系统高效运行
if [ $vm_fix = "true" ] ; then
chmod 0644 /proc/sys/*; 2>/dev/null
if [ $mode = "turbo" ] ; then
sysctl -e -w vm.dirty_background_ratio=3 2>/dev/null
sysctl -e -w vm.dirty_ratio=15 2>/dev/null
sysctl -e -w vm.vfs_cache_pressure=150 2>/dev/null
echo "* turbo模式下Virtual Memory优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
sysctl -e -w vm.dirty_background_ratio=35 2>/dev/null
sysctl -e -w vm.dirty_ratio=70 2>/dev/null
sysctl -e -w vm.vfs_cache_pressure=10 2>/dev/null
echo "* balance模式下Virtual Memory优化完毕" |  tee -a $LOG;
elif [ $mode = "powersave" ] ; then
sysctl -e -w vm.dirty_background_ratio=5 2>/dev/null
sysctl -e -w vm.dirty_ratio=20 2>/dev/null
sysctl -e -w vm.vfs_cache_pressure=10 2>/dev/null
echo "* powersave模式下Virtual Memory优化完毕" |  tee -a $LOG;
else
sysctl -e -w vm.dirty_background_ratio=3 2>/dev/null
sysctl -e -w vm.dirty_ratio=15 2>/dev/null
sysctl -e -w vm.vfs_cache_pressure=150 2>/dev/null
echo "* gamexe模式下Virtual Memory优化完毕" |  tee -a $LOG;
fi
sysctl -e -w vm.drop_caches=0 2>/dev/null
sysctl -e -w vm.oom_kill_allocating_task=0 2>/dev/null
sysctl -e -w vm.block_dump=0 2>/dev/null
sysctl -e -w vm.overcommit_memory=1 2>/dev/null
sysctl -e -w vm.oom_dump_tasks=1 2>/dev/null
sysctl -e -w vm.dirty_writeback_centisecs=0 2>/dev/null
sysctl -e -w vm.dirty_expire_centisecs=0 2>/dev/null
sysctl -e -w vm.min_free_order_shift=4 2>/dev/null
sysctl -e -w vm.swappiness=0 2>/dev/null
sysctl -e -w vm.page-cluster=0 2>/dev/null
sysctl -e -w vm.laptop_mode=0 2>/dev/null
sysctl -e -w fs.lease-break-time=10 2>/dev/null
sysctl -e -w fs.leases-enable=1 2>/dev/null
sysctl -e -w fs.dir-notify-enable=0 2>/dev/null
sysctl -e -w vm.compact_memory=1 2>/dev/null
sysctl -e -w vm.compact_unevictable_allowed=1 2>/dev/null
sysctl -e -w vm.panic_on_oom=0 2>/dev/null
sysctl -e -w kernel.panic_on_oops=0 2>/dev/null
sysctl -e -w kernel.panic=0 2>/dev/null
sysctl -e -w kernel.panic_on_warn=0 2>/dev/null
fi
#ZRAM调整
if [ -e /dev/block/zram0 ]; then
 swapoff /dev/block/zram0
 echo "1" > /sys/block/zram0/reset
 echo "$((ZR*1024*1024))" > /sys/block/zram0/disksize 
 mkswap /dev/block/zram0
 swapon /dev/block/zram0
 sysctl -e -w vm.swappiness=100
 setprop vnswap.enabled true
 setprop ro.config.zram true
 setprop ro.config.zram.support true
 setprop zram.disksize $ZR
 echo "* $ZR mb ZRAM已开启" |  tee -a $LOG;
fi;
if [ -e /dev/block/zram1 ]; then
 swapoff /dev/block/zram1
 echo "1" > /sys/block/zram1/reset
 echo "$((ZR*1024*1024))" > /sys/block/zram1/disksize 
 mkswap /dev/block/zram1
 swapon /dev/block/zram1
 sysctl -e -w vm.swappiness=100
 setprop vnswap.enabled true
 setprop ro.config.zram true
 setprop ro.config.zram.support true
 setprop zram.disksize $ZR
 echo "* $ZR mb ZRAM已开启" |  tee -a $LOG;
fi;
if [ -e /proc/sys/vm/swappiness ] ; then
chwrite 100 /proc/sys/vm/swappiness
fi
#优化IO以提升文件独写速度
if [ $io_fix = "true" ] ; then
if [ $qualcomm_soc = "true" ] ; then
if [ $mode = "turbo" ] ; then
IO_mode="row"
elif [ $mode = "gamexe" ] ; then
IO_mode="row"
else
IO_mode="deadline"
fi
else
IO_mode="deadline"
fi
MMC=$(ls -d /sys/block/mmc*)
DM=$(ls -d /sys/block/dm-*)
SD=$(ls -d /sys/block/sd*)
LOOP=$(ls -d /sys/block/loop*)
RAM=$(ls -d /sys/block/ram*)
SCH=$(cat $NFS/scheduler.txt)
if [ $mode = "gamexe" ]; then
 RQ=2
 NOM=0
 NR=128
 KB=2048
elif [ $mode = "turbo" ]; then
 RQ=2
 NOM=0
 NR=128
 KB=1024
elif [ $mode = "powersave" ]; then
 RQ=0
 NOM=0
 NR=64
 KB=256
elif [ $mode = "balance" ]; then
 RQ=2
 NOM=0
 NR=128
 KB=512
fi;
for X in $MMC $SD $DM $LOOP $RAM $ZR
do
 chwrite "$IO_mode" $X/queue/scheduler 2>/dev/null
 chwrite "0" $X/queue/rotational 2>/dev/null
 chwrite "0" $X/queue/iostats 2>/dev/null
 chwrite "0" $X/queue/add_random 2>/dev/null
 chwrite "$NR" $X/queue/nr_requests 2>/dev/null
 chwrite "$NOM" $X/queue/nomerges 2>/dev/null
 chwrite "$RQ" $X/queue/rq_affinity 2>/dev/null
 chwrite "$NR" $X/queue/read_ahead_kb 2>/dev/null
 chwrite "0" $X/queue/iosched/slice_idle 2>/dev/null
 chwrite "2" $X/queue/iosched/fifo_batch 2>/dev/null
 chwrite "0" $X/queue/iosched/front_merges 2>/dev/null
 chwrite "4" $X/queue/iosched/writes_starved 2>/dev/null
 chwrite "350" $X/queue/iosched/read_expire 2>/dev/null
 chwrite "3500" $X/queue/iosched/write_expire 2>/dev/null
 chwrite "350" $X/queue/iosched/sync_read_expire 2>/dev/null
 chwrite "3500" $X/queue/iosched/sync_write_expire 2>/dev/null
 chwrite "350" $X/queue/iosched/async_read_expire 2>/dev/null
 chwrite "3500" $X/queue/iosched/async_write_expire 2>/dev/null
 chwrite "10" $X/queue/iosched/async_scale 2>/dev/null
 chwrite "8" $X/queue/iosched/read_scale 2>/dev/null
 chwrite "8" $X/queue/iosched/sync_scale 2>/dev/null
 chwrite "12" $X/queue/iosched/write_scale 2>/dev/null
done
if [ "`ls /sys/devices/virtual/bdi/179*/read_ahead_kb`" ]; then
 for RH in /sys/devices/virtual/bdi/179*/read_ahead_kb
do
 chwrite "$KB" $RH
done
fi; 2>/dev/null
for I in `find /sys/devices/platform -name iostats`
do
 chwrite "0" $I
done
echo "* I/O性能优化完毕" |  tee -a $LOG;
fi
#优化Low Memory Killer以改善后台
if [ -e /sys/module/lowmemorykiller/parameters/minfree ] ; then
LIGHT=("1.25" "1.5" "1.75" "2" "2.75" "3.25")
BALANCED=("1.8" "1.25" "1.8" "2.8" "3.3" "4.25")
LITTLE=("1.25" "1.5" "3" "4.8" "5.5" "7")
setprop ro.sys.fw.bg_apps_limit 50
setprop ro.vendor.qti.sys.fw.bg_apps_limit 50
write /sys/module/lowmemorykiller/parameters/vmpressure_file_min 81250
LMK1=18432
LMK2=23040
LMK3=27648
LMK4=51200
LMK5=150296
LMK6=200640
calculator="2.6"
if [ $k_mode = "auto" ] ; then
if [ $mode = "powersave" ] ; then
c=("${LITTLE[@]}")
elif [ $mode = "balance" ] ; then
c=("${BALANCED[@]}")
elif [ $mode = "turbo" ] ; then
c=("${LIGHT[@]}")
else
c=("${LIGHT[@]}")
fi
elif [ $k_mode = "light" ] ; then
c=("${LIGHT[@]}")
elif [ $k_mode = "balanced" ] ; then
c=("${BALANCED[@]}")
elif [ $k_mode = "little" ] ; then
c=("${LITTLE[@]}")
else
c=("${BALANCED[@]}")
fi
f_LMK1=$(awk -v x=$LMK1 -v y=${c[0]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 1
LMK1=$(round ${f_LMK1} 0)
f_LMK2=$(awk -v x=$LMK2 -v y=${c[1]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 2
LMK2=$(round ${f_LMK2} 0)
f_LMK3=$(awk -v x=$LMK3 -v y=${c[2]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 3
LMK3=$(round ${f_LMK3} 0)
f_LMK4=$(awk -v x=$LMK4 -v y=${c[3]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 4
LMK4=$(round ${f_LMK4} 0)
f_LMK5=$(awk -v x=$LMK5 -v y=${c[4]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 5
LMK5=$(round ${f_LMK5} 0)
f_LMK6=$(awk -v x=$LMK6 -v y=${c[5]} -v z=$calculator 'BEGIN{print x*y*z}') #Low Memory Killer 6
LMK6=$(round ${f_LMK6} 0)
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then
chwrite 1 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
fi
if [ -e "/sys/module/lowmemorykiller/parameters/minfree" ]; then
chwrite "$LMK1,$LMK2,$LMK3,$LMK4,$LMK5,$LMK6" /sys/module/lowmemorykiller/parameters/minfree
fi
if [ -e "/sys/module/lowmemorykiller/parameters/oom_reaper" ]; then
chwrite 1 /sys/module/lowmemorykiller/parameters/oom_reaper
fi
echo "* Low Memory Killer强度已设置为$k_mode" |  tee -a $LOG
fi
#Deep Sleep Enhancement 优化
if [ $dse_fix = "true" ] ; then
for i in $(ls /sys/class/scsi_disk/); do
 chwrite "temporary none" /sys/class/scsi_disk/"$i"/cache_type
 if [ -e /sys/class/scsi_disk/"$i"/cache_type ]; then
  DP=1
 fi;
done
if [ "$DP" -eq "1" ]; then
 echo "* Deep Sleep Enhancement 优化完毕" |  tee -a $LOG;
fi;
fi
#Low Power Levels 优化
if [ $lpl_fix = "true" ] ; then
LPM=/sys/module/lpm_levels
if [ -d $LPM/parameters ]; then
 echo "4" > $LPM/enable_low_power/l2 2>/dev/null
 echo "Y" > $LPM/parameters/lpm_prediction 2>/dev/null
 echo "0" > $LPM/parameters/sleep_time_override 2>/dev/null
 echo "N" > $LPM/parameters/sleep_disable 2>/dev/null
 echo "N" > $LPM/parameters/menu_select 2>/dev/null
 echo "N" > $LPM/parameters/print_parsed_dt 2>/dev/null
 echo "100" > $LPM/parameters/red_stddev 2>/dev/null
 echo "100" > $LPM/parameters/tmr_add 2>/dev/null
 echo "Y" > $LPM/system/system-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/system-pc/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/system-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/system-wifi/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/perf-l2-dynret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-dynret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/perf-l2-ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/perf-l2-wifi/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/pwr-l2-dynret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-dynret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/pwr-l2-ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-wifi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/pwr-l2-wifi/suspend_enabled 2>/dev/null
for i in 4 5 6 7; do
 echo "Y" > $LPM/system/perf/cpu$i/pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/perf/cpu$i/ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/wfi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/perf/cpu$i/wfi/suspend_enabled 2>/dev/null
done
for i in 0 1 2 3; do
 echo "Y" > $LPM/system/pwr/cpu$i/pc/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/pc/suspend_enabled 2>/dev/null
 echo "N" > $LPM/system/pwr/cpu$i/ret/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/ret/suspend_enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/wfi/idle-enabled 2>/dev/null
 echo "Y" > $LPM/system/pwr/cpu$i/wfi/suspend_enabled 2>/dev/null
done
echo "* Low Power Levels 优化完毕" | tee  -a $LOG;
fi;
fi
#优化CPU多任务性能以提升系统流畅度
if [ -e /dev/cpuset/background/cpus ] ; then
if [ $core_num = "7" ] ; then
chwrite "2-3" /dev/cpuset/background/cpus 
chwrite "0-3" /dev/cpuset/system-background/cpus 
chwrite "0-3,4-7" /dev/cpuset/foreground/cpus 
chwrite "0-3,4-7" /dev/cpuset/top-app/cpus 
echo "* 八核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "3" ] ; then
#only 4core
chwrite "0-1" /dev/cpuset/background/cpus 
chwrite "0-1" /dev/cpuset/system-background/cpus 
chwrite "0-1,2-3" /dev/cpuset/foreground/cpus 
chwrite "0-1,2-3" /dev/cpuset/top-app/cpus 
echo "* 四核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "5" ] ; then
chwrite "2-3" /dev/cpuset/background/cpus 
chwrite "0-3" /dev/cpuset/system-background/cpus 
chwrite "0-3,4-5" /dev/cpuset/foreground/cpus
chwrite "0-3,4-5" /dev/cpuset/top-app/cpus
echo "* 六核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "9" ] ; then
chwrite "2-3" /dev/cpuset/background/cpus 
chwrite "0-3" /dev/cpuset/system-background/cpus 
chwrite "0-3,4-7,8-9" /dev/cpuset/foreground/cpus 
chwrite "4-7,8-9" /dev/cpuset/top-app/cpus 
echo "* 十核多任务优化已完成" |  tee -a $LOG;
else
#none
echo "* 未知核心多任务优化已完成" |  tee -a $LOG;
fi
fi
if [ $soc_type = "high" ] ; then
if [ $mode = "turbo" ] ; then
chwrite 55 /proc/sys/kernel/sched_downmigrate
chwrite 65 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 75 /proc/sys/kernel/sched_downmigrate
chwrite 85 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 85 /proc/sys/kernel/sched_downmigrate
chwrite 95 /proc/sys/kernel/sched_upmigrate
else
chwrite 45 /proc/sys/kernel/sched_downmigrate
chwrite 55 /proc/sys/kernel/sched_upmigrate
fi
if [ -e /proc/sys/kernel/sched_downmigrate ] ; then
if [ $mode = "gamexe" ] ; then
chwrite 50 /proc/sys/kernel/sched_downmigrate
chwrite 50 /proc/sys/kernel/sched_upmigrate
chwrite 8 /proc/sys/kernel/sched_spill_nr_run
chwrite 85 /proc/sys/kernel/sched_spill_load
elif [ $mode = "turbo" ] ; then
chwrite 70 /proc/sys/kernel/sched_downmigrate
chwrite 70 /proc/sys/kernel/sched_upmigrate
chwrite 5 /proc/sys/kernel/sched_spill_nr_run
chwrite 95 /proc/sys/kernel/sched_spill_load
else
chwrite 90 /proc/sys/kernel/sched_downmigrate
chwrite 90 /proc/sys/kernel/sched_upmigrate
chwrite 3 /proc/sys/kernel/sched_spill_nr_run
chwrite 100 /proc/sys/kernel/sched_spill_load
fi
echo "* $mode模式下CPU核心负载策略已调整" |  tee -a $LOG;
fi
elif [ $soc_type = "mid" ] ; then
if [ $mode = "turbo" ] ; then
chwrite 40 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 50 /proc/sys/kernel/sched_downmigrate
chwrite 70 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 60 /proc/sys/kernel/sched_downmigrate
chwrite 80 /proc/sys/kernel/sched_upmigrate
else
chwrite 30 /proc/sys/kernel/sched_downmigrate
chwrite 50 /proc/sys/kernel/sched_upmigrate
fi
if [ -e /proc/sys/kernel/sched_downmigrate ] ; then
if [ $mode = "gamexe" ] ; then
chwrite 40 /proc/sys/kernel/sched_downmigrate
chwrite 40 /proc/sys/kernel/sched_upmigrate
chwrite 10 /proc/sys/kernel/sched_spill_nr_run
chwrite 75 /proc/sys/kernel/sched_spill_load
elif [ $mode = "turbo" ] ; then
chwrite 60 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
chwrite 6 /proc/sys/kernel/sched_spill_nr_run
chwrite 85 /proc/sys/kernel/sched_spill_load
else
chwrite 80 /proc/sys/kernel/sched_downmigrate
chwrite 80 /proc/sys/kernel/sched_upmigrate
chwrite 3 /proc/sys/kernel/sched_spill_nr_run
chwrite 95 /proc/sys/kernel/sched_spill_load
fi
echo "* $mode模式下CPU核心负载策略已调整" |  tee -a $LOG;
fi
elif [ $soc_type = "low" ] ; then
if [ $mode = "turbo" ] ; then
chwrite 30 /proc/sys/kernel/sched_downmigrate
chwrite 50 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 40 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 50 /proc/sys/kernel/sched_downmigrate
chwrite 70 /proc/sys/kernel/sched_upmigrate
else
chwrite 20 /proc/sys/kernel/sched_downmigrate
chwrite 40 /proc/sys/kernel/sched_upmigrate
fi
if [ -e /proc/sys/kernel/sched_downmigrate ] ; then
if [ $mode = "gamexe" ] ; then
chwrite 30 /proc/sys/kernel/sched_downmigrate
chwrite 30 /proc/sys/kernel/sched_upmigrate
chwrite 10 /proc/sys/kernel/sched_spill_nr_run
chwrite 75 /proc/sys/kernel/sched_spill_load
elif [ $mode = "turbo" ] ; then
chwrite 60 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
chwrite 6 /proc/sys/kernel/sched_spill_nr_run
chwrite 85 /proc/sys/kernel/sched_spill_load
else
chwrite 90 /proc/sys/kernel/sched_downmigrate
chwrite 90 /proc/sys/kernel/sched_upmigrate
chwrite 3 /proc/sys/kernel/sched_spill_nr_run
chwrite 100 /proc/sys/kernel/sched_spill_load
fi
echo "* $mode模式下CPU核心负载策略已调整" |  tee -a $LOG;
fi
fi
#调整电源策略及GPU加速策略以提升游戏体验/续航
if [ $mode = "gamexe" ] ; then
if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/workqueue/parameters/power_efficient
fi;
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
if [ -e /sys/kernel/sched/arch_power ]; then
echo "0" > /sys/kernel/sched/arch_power
fi;
echo "* gamexe模式下游戏性能优化完毕" |  tee -a $LOG;
elif [ $mode = "turbo" ] ; then
if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/workqueue/parameters/power_efficient
fi;
if [ -e /sys/kernel/sched/arch_power ]; then
echo "0" > /sys/kernel/sched/arch_power
fi;
echo "* turbo模式下游戏性能优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
fi;
if [ -e /sys/kernel/sched/arch_power ]; then
echo "1" > /sys/kernel/sched/arch_power
fi;
echo "* balance模式下省电优化完毕" |  tee -a $LOG;
else
if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
fi;
if [ -e /sys/kernel/sched/arch_power ]; then
echo "1" > /sys/kernel/sched/arch_power
fi;
echo "* powersave模式下省电优化完毕" |  tee -a $LOG;
fi
#附加优化
case $SOC in hi*)
#Hisilicon
echo "* Hisilicon附加优化完毕" |  tee -a $LOG;
esac
case $SOC in mt*)
#MediaTek
setprop ro.mtk_perfservice_support 0
chwrite 0 "/proc/sys/kernel/sched_tunable_scaling"
chwrite 0 "/proc/ppm/policy/hica_is_limit_big_freq"
chwrite 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
if [ $mode = "turbo" ] ; then
chwrite 50 /proc/hps/up_threshold
echo "* turbo 模式下MediaTek CPU优化完毕" |  tee -a $LOG;
elif [ $mode = "gamexe" ] ; then
chwrite 30 /proc/hps/up_threshold
echo "* gamexe 模式下MediaTek CPU优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
chwrite 70 /proc/hps/up_threshold
echo "* balance 模式下MediaTek CPU优化完毕" |  tee -a $LOG;
elif [ $mode = "powersave" ] ; then
chwrite 90 /proc/hps/up_threshold
echo "* powersave 模式下MediaTek CPU优化完毕" |  tee -a $LOG;
fi
chwrite 40 /proc/hps/down_threshold
echo "* MediaTek附加优化完毕" |  tee -a $LOG;
esac
#执行fstrim，优化磁盘性能
fstrim -v /cache
fstrim -v /data
fstrim -v /system
echo "* Fstrim 执行完毕" |  tee -a $LOG;
#结束程序
echo "* 感受FastTurbo带来的强劲性能吧." |  tee -a $LOG;
FastTurbo
exit 0
