#!/system/bin/sh
#------------------------------------------------------
#FastTurbo Boost 
#Author:@Chenzyadb (xda,coolapk,bilibili)
#Opensource Licence : modpath/license.txt
#Copyright © Chenzyadb 2019 All Rights Reserved.
#------------------------------------------------------
#由于本人常常忘记缩进，所以代码逻辑有些混乱，请不要在意这些细节.
#修改关键配置文件权限
chmod 7777 /system/priv-app/FastTurbo/base.apk 
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
#LOG记录
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
function set_io() {    #I/O调整
	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			chwrite 0 $2/queue/iostats
			chwrite 128 $2/queue/nr_requests
			chwrite 0 $2/queue/iosched/slice_idle
			chwrite 1 $2/queue/rq_affinity
			chwrite 1 $2/queue/nomerges
			chwrite 0 $2/queue/add_random
			chwrite 0 $2/queue/rotational
			chwrite 0 $2/bdi/min_ratio
			chwrite 100 $2/bdi/max_ratio
			chwrite 2048 /sys/devices/virtual/bdi/179:0/read_ahead_kb
			if [ $1 = "cfq" ] ; then
			write $2/queue/read_ahead_kb 256
			else
			write $2/queue/read_ahead_kb 2048
			fi
  		fi
	fi
}
function set_param() {   #修改CPU参数1
	echo $4 > /sys/devices/system/cpu/$2/cpufreq/$1/$3
}
function set_param_eas() {     #修改CPU参数2
	echo $4 > /sys/devices/system/cpu/$2/cpufreq/$1/$3
}
#得到SOC型号
SOC=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'`
if  [ $SOC = "" ] ; then
SOC=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'`
fi
#得到GPU信息
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/class/kgsl/kgsl-3d0"
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
	elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	GPU_DIR="/sys/devices/platform/*.gpu/devfreq/*.gpu"	
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	GPU_DIR="/sys/devices/platform/gpusysfs"
	elif [ -d "/sys/devices/*.mali" ]; then
	GPU_DIR="/sys/devices/*.mali"
	elif [ -d "/sys/devices/*.gpu" ]; then
	GPU_DIR="/sys/devices/*.gpu"
	elif [ -d "/sys/devices/platform/mali.0" ]; then
	GPU_DIR="/sys/devices/platform/mali.0"
	elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	GPU_DIR="/sys/devices/platform/mali-*.0"
	elif [ -d "/sys/module/mali/parameters" ]; then
	GPU_DIR="/sys/module/mali/parameters"
	elif [ -d "/sys/class/misc/mali0" ]; then
	GPU_DIR="/sys/class/misc/mali0"
	elif [ -d "/sys/kernel/gpu" ]; then
	GPU_DIR="/sys/kernel/gpu"
fi
if [ -e "$GPU_DIR/devfreq/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/*.mali/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/devfreq/*.gpu/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/available_frequencies) 2>/dev/null
fi
GPU_MIN="$(min $GPU_FREQS)"
GPU_MAX="$(max $GPU_FREQS)"
if [ ! -e ${GPU_FREQS} ]; then
	GPU_MIN=$(cat "$GPU_DIR/devfreq/min_freq") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/devfreq/max_freq") 2>/dev/null	
fi
if [ ! -e ${GPU_DIR}/devfreq/max_freq ] && [ ! -e ${GPU_DIR}/devfreq/max_freq ]; then
	GPU_MIN=$(cat "$GPU_DIR/gpuclk") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/max_gpuclk") 2>/dev/null	
fi
#得到CPU信息
freq0=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
freq1=`cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq`
freq2=`cat /sys/devices/system/cpu/cpu2/cpufreq/cpuinfo_max_freq`
freq3=`cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq`
freq4=`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq`
freq5=`cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq`
freq6=`cat /sys/devices/system/cpu/cpu6/cpufreq/cpuinfo_max_freq`
freq7=`cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq`
freq8=`cat /sys/devices/system/cpu/cpu8/cpufreq/cpuinfo_max_freq`
freq9=`cat /sys/devices/system/cpu/cpu9/cpufreq/cpuinfo_max_freq`
core_num=`cat /sys/devices/system/cpu/kernel_max`
#得到RAM信息
ram_value=$(free | grep Mem | awk '{print $2}')
#得到模块配置参数
mode=`cat /data/FastTurbo/mode`
zram_mode=`cat /data/FastTurbo/zmode`
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
#得到游戏信息
#game_mode=0,none;game_mode=1,GPU+,CPU-;game_mode=2,GPU-,CPU+;game_mode=3,GPU+,CPU+.
if [ $mode = "gamexe" ] ; then
game_mode="0"
game_name=""
if [ -d /data/user/0/com.miHoYo.bh3* ] ; then
#崩坏3
 game_mode="1"
 game_name="bh3"
fi 
if [ -d /data/user/0/com.netease.onmyoji* ] ; then
#阴阳师
 if [ $game_mode = "1" ] ; then
  game_mode="3"
 else
  game_mode="2"
 fi
 if [ $game_name = "bh3" ] ; then 
  game_name="all"
 else
  game_name="yys"
 fi
fi
if [ -d /data/user/0/com.tencent.tmgp.sgame ] ; then 
#王者荣耀
 game_mode="3"
 game_name="wzyr"
fi
if [ $game_mode = "0" ] ; then
#未适配的游戏
 game_mode="3"
 game_name="all"
fi
fi
#得到手机信息
tinfo=$(date +"%d-%m-%Y %r")
sdk=`getprop ro.build.version.sdk | tr '[:upper:]' '[:lower:]'`
aver=`getprop ro.build.version.release | tr '[:upper:]' '[:lower:]'`
vendor=`getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]'`
id=`getprop ro.product.model | tr '[:upper:]' '[:lower:]'`
#手机和模块信息显示
echo "时间：$tinfo " > /data/FastTurbo/FastTurbo.log
echo "=========================" |  tee -a $LOG;
echo "* SOC型号：$SOC" |  tee -a $LOG;
echo "* Android Verson: $aver" |  tee -a $LOG;
echo "* Android SDK: $sdk" |  tee -a $LOG;
echo "* 制造商：$vendor" |  tee -a $LOG;
echo "* 手机型号：$id" |  tee -a $LOG;
echo "* 核心频率获取完毕，频率列表如下：" |  tee -a $LOG;
echo "* $freq0 $freq1 $freq2 $freq3" |  tee -a $LOG;
echo "* $freq4 $freq5 $freq6 $freq7" |  tee -a $LOG;
if [ $core_num = "9" ] ; then
echo "* $freq8 $freq9" |  tee -a $LOG;
fi
echo "* 内存大小：$ram_value" |  tee -a $LOG;
if [ $mode = "gamexe" ] ; then
echo "* FastTurbo处于Game X Extreme模式" |  tee -a $LOG;
elif [ $mode = "turbo" ] ; then
echo "* FastTurbo处于性能模式" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
echo "* FastTurbo处于均衡模式" |  tee -a $LOG;
else
echo "* FastTurbo处于超级省电模式" |  tee -a $LOG;
fi
echo "=========================" |  tee -a $LOG;
echo "* FastTurbo初始化完毕" |  tee -a $LOG;
wmode="/data/FastTurbo/mode"
if [ $mode = "" ] ; then
echo "* 获取预设模式失败，已调整为turbo" |  tee -a $LOG;
mode="turbo"
echo "turbo" > $wmode
fi
#--------------------------------------------------------
echo "===开始兼容性检查===" |  tee -a $LOG;
if [ ! -d /sys/devices/system/cpu/ ] ; then
 echo "* 内核不支持CPU控制" |  tee -a $LOG;
fi
if [ ! -e /sys/module/bcmdhd/parameters/wlrx_divide ] ; then
 echo "* 内核不支持WLAN Wakelocks" |  tee -a $LOG;
fi
if [ ! -d /sys/module/cpu_boost/parameters/ ] ; then
 echo "* 内核不支持CPU Boost" |  tee -a $LOG;
fi
if [ ! -e /sys/class/power_supply/bms/temp_warm ] ; then
 echo "* 内核不支持快充温度阈值调整" |  tee -a $LOG;
fi
if [ ! -e /sys/module/wakeup/parameters/enable_bluetooth_timer ] ; then
 echo "* 内核不支持wakelocks" |  tee -a $LOG;
fi
if [ ! -e /sys/kernel/debug/sched_features ] ; then
 if [ ! -d /proc/sys/fs/ ] ; then
  if [ ! -e /proc/sys/vm/page-cluster ] ; then
   echo "* 系统内核参数不支持调整" |  tee -a $LOG;
  fi
 fi
fi 
if [ ! -e sys/kernel/gpu/gpu_governor ] ; then
 echo "* 内核不支持GPU调频器调整" |  tee -a $LOG;  
fi
if [ ! -e $GPU_DIR/devfreq/adrenoboost ] ; then
 echo "* 内核不支持Adreno Boost" |  tee -a $LOG;
fi
if [ ! -e $GPU_DIR/devfreq/target_freq ] ; then
 echo "* 内核不支持GPU频率调整" |  tee -a $LOG;
fi
if [ ! -e /sys/block/zram0/reset ] ; then
 echo "* 内核不支持ZRAM大小调整" |  tee -a $LOG; 
fi
if [ ! -e /sys/module/lowmemorykiller/parameters/minfree ] ; then
 echo "* 内核不支持Low Memory Killer参数调整" |  tee -a $LOG; 
fi
if [ ! -d /sys/module/lpm_levels/ ] ; then
 echo "* 内核不支持Low Power Mode Levels参数调整" |  tee -a $LOG; 
fi
if [ ! -e /dev/cpuset/system-background/cpus ] ; then
 if [ ! -e /proc/sys/kernel/sched_downmigrate ] ; then
   echo "* 内核不支持CPU多任务优化" |  tee -a $LOG;  
 fi
fi 
if [ ! -e /sys/module/workqueue/parameters/power_efficient ] ; then
 echo "* 内核不支持省电/游戏优化" |  tee -a $LOG;  
fi
if [ ! -e /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk ] ; then
 echo "* 内核不支持Deep Sleep Enhancement优化" |  tee -a $LOG;
fi 
echo "===兼容性检查完毕===" |  tee -a $LOG;
#--------------------------------------------------------
#干掉高通热插拔
# Performance daemon
stop "perfd"
# Thermal daemon
stop "thermald"
# mpdecision
stop "mpdecision"
stop "thermal-engine"
# perflock HAL
stop "perf-hal-1-0"
chwrite 0 /sys/module/msm_thermal/core_control/enabled
chwrite 0 /proc/hps/enable
chwrite 0 /sys/module/msm_thermal/parameters/enabled
chwrite 0 /sys/power/cpuhotplug/enabled
chwrite 0 /sys/devices/system/cpu/cpuhotplug/enabled
echo "* 温控优化完毕" |  tee -a $LOG;
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
#CPU设定优化
write "/dev/stune/schedtune.boost" 0
write "/dev/stune/schedtune.prefer_idle" 1
write "/dev/stune/cgroup.clone_children" 0
write "/dev/stune/cgroup.sane_behavior" 0
write "/dev/stune/notify_on_release" 0
write "/dev/stune/top-app/schedtune.sched_boost" 0
write "/dev/stune/top-app/notify_on_release" 0
write "/dev/stune/top-app/cgroup.clone_children" 0
write "/dev/stune/foreground/schedtune.sched_boost" 0
write "/dev/stune/foreground/notify_on_release" 0
write "/dev/stune/foreground/cgroup.clone_children" 0
write "/dev/stune/background/schedtune.sched_boost" 0
write "/dev/stune/background/notify_on_release" 0
write "/dev/stune/background/cgroup.clone_children" 0
write "/proc/sys/kernel/sched_use_walt_task_util" 1
write "/proc/sys/kernel/sched_use_walt_cpu_util" 1
write "/proc/sys/kernel/sched_walt_cpu_high_irqload" 10000000
write "/proc/sys/kernel/sched_rt_runtime_us" 950000	
write "/proc/sys/kernel/sched_latency_ns" 100000
write "/dev/cpuset/cgroup.clone_children" 0
write "/dev/cpuset/cgroup.sane_behavior" 0
write "/dev/cpuset/notify_on_release" 0
write "/dev/cpuctl/cgroup.clone_children" 0
write "/dev/cpuctl/cgroup.sane_behavior" 0
write "/dev/cpuctl/notify_on_release" 0
write "/dev/cpuctl/cpu.rt_period_us" 1000000
write "/dev/cpuctl/cpu.rt_runtime_us" 950000
write "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us" 10000
chwrite 1 "/dev/stune/top-app/schedtune.prefer_idle"
chwrite 1 "/dev/stune/foreground/schedtune.prefer_idle"
chwrite 0 "/dev/stune/background/schedtune.prefer_idle"
chwrite 0 "/dev/stune/rt/schedtune.prefer_idle"
echo "* CPU核心控制启动完毕" |  tee -a $LOG;
#调整快充温控阈值
if [ $temp_fix = "true" ] ; then
 if [ $mode = "gamexe" ] ; then
  chwrite 500 /sys/class/power_supply/bms/temp_warm
  chwrite 150 /sys/class/power_supply/bms/temp_cool
 elif [ $mode = "turbo" ] ; then
  chwrite 600 /sys/class/power_supply/bms/temp_warm
  chwrite 200 /sys/class/power_supply/bms/temp_cool
 else
  chwrite 450 /sys/class/power_supply/bms/temp_warm
  chwrite 100 /sys/class/power_supply/bms/temp_cool
 fi
echo "* 快充温度阀值已自动调整" |  tee -a $LOG;
fi
#powersave模式下关闭核心以省电
if [ $mode = "powersave" ] ; then
if [ $core_num = "9" ] ; then
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
chwrite 0 /sys/devices/system/cpu/cpu1/online
chwrite 0 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 1 /sys/devices/system/cpu/cpu6/online
chwrite 0 /sys/devices/system/cpu/cpu7/online
elif [ $core_num = "5" ] ; then
chwrite 0 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 0 /sys/devices/system/cpu/cpu5/online
elif [ $core_num = "3" ] ; then
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 0 /sys/devices/system/cpu/cpu3/online
elif [ $core_num = "1" ] ; then
chwrite 0 /sys/devices/system/cpu/cpu1/online
fi
else
#将所有核心启动
chwrite 1 /sys/devices/system/cpu/cpu1/online
chwrite 1 /sys/devices/system/cpu/cpu2/online
chwrite 1 /sys/devices/system/cpu/cpu3/online
chwrite 1 /sys/devices/system/cpu/cpu4/online
chwrite 1 /sys/devices/system/cpu/cpu5/online
chwrite 1 /sys/devices/system/cpu/cpu6/online
chwrite 1 /sys/devices/system/cpu/cpu7/online
chwrite 1 /sys/devices/system/cpu/cpu8/online
chwrite 1 /sys/devices/system/cpu/cpu9/online
fi
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
chwrite “8″ /proc/sys/vm/page-cluster
chwrite “64000″ /proc/sys/kernel/msgmni
chwrite “64000″ /proc/sys/kernel/msgmax
chwrite “10″ /proc/sys/fs/lease-break-time
chwrite “500,512000,64,2048″ /proc/sys/kernel/sem
if [ -e /sys/kernel/debug/sched_features ]; then
 echo "NO_NORMALIZED_SLEEPER" > /sys/kernel/debug/sched_features 
 echo "GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features 
 echo "NO_NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features 
 echo "WAKEUP_PREEMPT" > /sys/kernel/debug/sched_features
 echo "NO_AFFINE_WAKEUPS" > /sys/kernel/debug/sched_features 
fi;
if [ -e /sys/kernel/sched/gentle_fair_sleepers ]; then
 echo "0" > /sys/kernel/sched/gentle_fair_sleepers
fi;
#关闭不必要的调试项
write "/sys/module/earlysuspend/parameters/debug_mask" 0
write "/sys/module/alarm/parameters/debug_mask" 0
write "/sys/module/alarm_dev/parameters/debug_mask" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/devices/system/edac/cpu/log_ce" 0
write "/sys/devices/system/edac/cpu/log_ue" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"
write "/sys/module/debug/parameters/enable_event_log" 0
write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" 0 
write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ce" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ue" 0
write "/sys/module/glink/parameters/debug_mask" 0
write "/sys/module/hid_apple/parameters/fnmode" 0
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
write "/sys/module/lowmemorykiller/parameters/debug_level" 0
write "/sys/module/mdss_fb/parameters/backlight_dimmer" "N"
write "/sys/module/msm_show_resume_irq/parameters/debug_mask" 0
write "/sys/module/msm_smd/parameters/debug_mask" 0
write "/sys/module/msm_smem/parameters/debug_mask" 0 
write "/sys/module/otg_wakelock/parameters/enabled" "N" 
write "/sys/module/service_locator/parameters/enable" 0 
write "/sys/module/sit/parameters/log_ecn_error" "N"
write "/sys/module/smem_log/parameters/log_enable" 0
write "/sys/module/smp2p/parameters/debug_mask" 0
write "/sys/module/sync/parameters/fsync_enabled" "N"
write "/sys/module/touch_core_base/parameters/debug_mask" 0
write "/sys/module/usb_bam/parameters/enable_event_log" 0
write "/sys/module/printk/parameters/console_suspend" "Y"
write "/proc/sys/debug/exception-trace" 0
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/compat-log" "0"
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;
if [ -e /sys/module/printk/parameters/console_suspend ]; then
 write /sys/module/printk/parameters/console_suspend 'Y'
fi;
for i in $(find /sys/ -name debug_mask); do
 write $i 0;
done
for i in $(find /sys/ -name debug_level); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
 write $i 0;
done
for i in $(find /sys/ -name enable_event_log); do
 write $i 0;
done
for i in $(find /sys/ -name log_ecn_error); do
 write $i 0;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
 write $i 0;
done
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
write /sys/kernel/fp_boost/enabled 1
fi
echo "* 触控优化完毕" |  tee -a $LOG;
#GPU优化部分
if [ $mode = "gamexe" ] ; then
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
elif [ $mode = "turbo" ] ; then
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
elif [ $mode = "balance" ] ; then
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
fi
GPU_GOV=`cat $GPU_DIR/devfreq/available_governors`
GPU_PWR=$(cat $GPU_DIR/num_pwrlevels) 2>/dev/null
GPU_PWR=$(($GPU_PWR-1))
GPU_BATT=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)-0.5)}')
GPU_BATT=$(round ${GPU_BATT} 0)
GPU_TURBO=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)+0.5)}')
GPU_TURBO=$(round ${GPU_TURBO} 0)
if [ $mode = "gamexe" ] ; then
if [ $game_mode = "2" ] ; then
#使用默认GPU调度以降低功耗
echo "msm-adreno-tz" > sys/kernel/gpu/gpu_governor
else
echo "simple_ondemand" > sys/kernel/gpu/gpu_governor
fi
elif [ $mode = "powersave" ] ; then
echo "msm-adreno-tz" > sys/kernel/gpu/gpu_governor
elif [ $mode = "turbo" ] ; then
echo "simple_ondemand" > sys/kernel/gpu/gpu_governor
elif [ $mode = "balance" ] ; then
echo "msm-adreno-tz" > sys/kernel/gpu/gpu_governor
fi
if [ $mode = "gamexe" ] ; then
if [ $game_mode = "2" ] ; then
#减少GPU调试以降低功耗
else
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MAX "$GPU_DIR/devfreq/target_freq" 
chwrite 0 "$GPU_DIR/throttling"
chwrite 0 "$GPU_DIR/force_no_nap"
chwrite 1 "$GPU_DIR/bus_split"
chwrite 0 "$GPU_DIR/force_bus_on"
chwrite 0 "$GPU_DIR/force_clk_on"
chwrite 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1
fi
elif [ $mode = "turbo" ] ; then
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/target_freq" 
chwrite 0 "$GPU_DIR/throttling"
chwrite 0 "$GPU_DIR/force_no_nap"
chwrite 1 "$GPU_DIR/bus_split"
chwrite 0 "$GPU_DIR/force_bus_on"
chwrite 0 "$GPU_DIR/force_clk_on"
chwrite 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1
elif [ $mode = "balance" ] ; then
chwrite $GPU_MAX "$GPU_DIR/max_gpuclk"
chwrite $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
chwrite $GPU_MIN "$GPU_DIR/devfreq/target_freq" 
chwrite 0 "$GPU_DIR/throttling"
chwrite 0 "$GPU_DIR/force_no_nap"
chwrite 1 "$GPU_DIR/bus_split"
chwrite 0 "$GPU_DIR/force_bus_on"
chwrite 0 "$GPU_DIR/force_clk_on"
chwrite 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1
fi
if [ $mode = "gamexe" ] ; then
if [ $game_mode = "2" ] ; then
else
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
chwrite 0 "$GPU_DIR/throttling"
chwrite 0 "$GPU_DIR/force_no_nap"
chwrite 1 "$GPU_DIR/bus_split"
chwrite 0 "$GPU_DIR/force_bus_on"
chwrite 0 "$GPU_DIR/force_clk_on"
chwrite 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1
chwrite 0 "$GPU_DIR/max_pwrlevel"
chwrite $GPU_TURBO "$GPU_DIR/min_pwrlevel"
chwrite 1 "$GPU_DIR/force_no_nap"
chwrite 0 "$GPU_DIR/bus_split"
chwrite 1 "$GPU_DIR/force_bus_on"
chwrite 1 "$GPU_DIR/force_clk_on"
chwrite 1 "$GPU_DIR/force_rail_on"
fi
echo "* gamexe模式下GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "turbo" ] ; then
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
chwrite 0 "$GPU_DIR/max_pwrlevel"
chwrite $GPU_PWR "$GPU_DIR/min_pwrlevel"
chwrite 1 "$GPU_DIR/force_no_nap"
echo "* turbo模式下GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "1" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
chwrite 0 "$GPU_DIR/max_pwrlevel"
chwrite $GPU_PWR "$GPU_DIR/min_pwrlevel"
echo "* balance模式下GPU优化完毕" |  tee -a $LOG;
else
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
chmod 0644 /sys/module/adreno_idler/parameters/adreno_idler_active
echo "1" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi;
#powersave模式禁用一切GPU优化
echo "* powersave模式下GPU优化完毕" |  tee -a $LOG;
fi
if [ $adreno_mode = "max" ] ; then
if [ -e $GPU_DIR/devfreq/adrenoboost ]; then 
 echo "3" > $GPU_DIR/devfreq/adrenoboost
fi;
echo "* adreno加速max模式已启用" |  tee -a $LOG;
elif [ $adreno_mode = "mid" ] ; then
if [ -e $GPU_DIR/devfreq/adrenoboost ]; then 
 echo "2" > $GPU_DIR/devfreq/adrenoboost
fi;
echo "* adreno加速mid模式已启用" |  tee -a $LOG;
elif [ $adreno_mode = "low" ] ; then
if [ -e $GPU_DIR/devfreq/adrenoboost ]; then 
 echo "1" > $GPU_DIR/devfreq/adrenoboost
fi;
echo "* adreno加速low模式已启用" |  tee -a $LOG;
else
if [ -e $GPU_DIR/devfreq/adrenoboost ]; then 
 echo "0" > $GPU_DIR/devfreq/adrenoboost
fi;
echo "* adreno加速已禁用" |  tee -a $LOG;
fi
#CPU优化部分
if [ $mode = "turbo" ] ; then
GOV="interactive"
elif [ $mode = "balance" ] ; then
GOV="ondemand"
elif [ $mode = "gamexe" ] ; then
if [ game_mode = "1" ] ; then
GOV="ondemand"
else
GOV="interactive"
fi
elif [ $mode = "powersave" ] ; then
GOV="ondemand"
fi
ML=/sys/devices/system/cpu/cpu0/cpufreq/$GOV
MB=/sys/devices/system/cpu/cpu5/cpufreq/$GOV
if [ -e /sys/devices/system/cpu/cpufreq/$GOV ]; then
ML=/sys/devices/system/cpu/cpufreq/$GOV
fi
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
 echo "* in下频率调整策略优化完毕" |  tee -a $LOG;
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
 echo "* balance/powersave模式下频率调整策略优化完毕" |  tee -a $LOG;
fi
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
if [ $game_mode = "1" ] ; then
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
else
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
fi
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
if [ $zram_mode = "1024" ] ; then
ZR="1024"
elif [ $zram_mode = "512" ] ; then
ZR="512" 
elif [ $zram_mode = "256" ] ; then
ZR="256"
else
ZR="0"
fi
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
chwrite 100 /proc/sys/vm/swappiness
#优化IO以提升文件独写速度
if [ $io_fix = "true" ] ; then
set_io deadline /sys/block/mmcblk0
set_io deadline /sys/block/sda
echo "* I/O性能优化完毕" |  tee -a $LOG;
fi
#优化Low Memory Killer以改善后台
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
f_LMK1=$(awk -v x=$LMK1 -v y=${c[0]} -v z=$calculator 'BEGIN{print x*y*z}') 
LMK1=$(round ${f_LMK1} 0)
f_LMK2=$(awk -v x=$LMK2 -v y=${c[1]} -v z=$calculator 'BEGIN{print x*y*z}') 
LMK2=$(round ${f_LMK2} 0)
f_LMK3=$(awk -v x=$LMK3 -v y=${c[2]} -v z=$calculator 'BEGIN{print x*y*z}') 
LMK3=$(round ${f_LMK3} 0)
f_LMK4=$(awk -v x=$LMK4 -v y=${c[3]} -v z=$calculator 'BEGIN{print x*y*z}') 
LMK4=$(round ${f_LMK4} 0)
f_LMK5=$(awk -v x=$LMK5 -v y=${c[4]} -v z=$calculator 'BEGIN{print x*y*z}') 
LMK5=$(round ${f_LMK5} 0)
f_LMK6=$(awk -v x=$LMK6 -v y=${c[5]} -v z=$calculator 'BEGIN{print x*y*z}') 
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
#Deep Sleep Enhancement 优化
if [ $dse_fix = "true" ] ; then
for i in $(ls /sys/class/scsi_disk/); do
 echo "temporary none" > /sys/class/scsi_disk/"$i"/cache_type
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
if [ $core_num = "7" ] ; then
write /dev/cpuset/background/cpus "2-3"
write /dev/cpuset/system-background/cpus "0-3"
write /dev/cpuset/foreground/cpus "0-3,4-7"
write /dev/cpuset/top-app/cpus "0-3,4-7"
if [ $mode = "turbo" ] ; then
chwrite 25 /proc/sys/kernel/sched_downmigrate
chwrite 35 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 35 /proc/sys/kernel/sched_downmigrate
chwrite 55 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 55 /proc/sys/kernel/sched_downmigrate
chwrite 75 /proc/sys/kernel/sched_upmigrate
else
if [ $game_mode = "1" ] ; then
chwrite 55 /proc/sys/kernel/sched_downmigrate
chwrite 75 /proc/sys/kernel/sched_upmigrate
else
chwrite 20 /proc/sys/kernel/sched_downmigrate
chwrite 30 /proc/sys/kernel/sched_upmigrate
fi
fi
echo "* 八核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "3" ] ; then
#only 4core
write /dev/cpuset/background/cpus "0-1"
write /dev/cpuset/system-background/cpus "0-1"
write /dev/cpuset/foreground/cpus "0-1,2-3"
write /dev/cpuset/top-app/cpus "0-1,2-3"
if [ $mode = "turbo" ] ; then
chwrite 25 /proc/sys/kernel/sched_downmigrate
chwrite 45 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 30 /proc/sys/kernel/sched_downmigrate
chwrite 50 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 40 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
else
if [ $game_mode = "1" ] ; then
chwrite 40 /proc/sys/kernel/sched_downmigrate
chwrite 60 /proc/sys/kernel/sched_upmigrate
else
chwrite 15 /proc/sys/kernel/sched_downmigrate
chwrite 35 /proc/sys/kernel/sched_upmigrate
fi
fi
echo "* 四核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "5" ] ; then
write /dev/cpuset/background/cpus "2-3"
write /dev/cpuset/system-background/cpus "0-3"
chwrite 0-3,4-5 /dev/cpuset/foreground/cpus
chwrite 0-3,4-5 /dev/cpuset/top-app/cpus
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
if [ $game_mode = "1" ] ; then
chwrite 60 /proc/sys/kernel/sched_downmigrate
chwrite 80 /proc/sys/kernel/sched_upmigrate
else
chwrite 20 /proc/sys/kernel/sched_downmigrate
chwrite 30 /proc/sys/kernel/sched_upmigrate
fi
fi
echo "* 六核多任务优化已完成" |  tee -a $LOG;
elif [ $core_num = "9" ] ; then
write /dev/cpuset/background/cpus "2-3"
write /dev/cpuset/system-background/cpus "0-3"
write /dev/cpuset/foreground/cpus "0-3,4-7,8-9"
write /dev/cpuset/top-app/cpus "4-7,8-9"
if [ $mode = "turbo" ] ; then
chwrite 25 /proc/sys/kernel/sched_downmigrate
chwrite 35 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 35 /proc/sys/kernel/sched_downmigrate
chwrite 55 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 55 /proc/sys/kernel/sched_downmigrate
chwrite 75 /proc/sys/kernel/sched_upmigrate
else
if [ $game_mode = "1" ] ; then
chwrite 55 /proc/sys/kernel/sched_downmigrate
chwrite 75 /proc/sys/kernel/sched_upmigrate
else
chwrite 20 /proc/sys/kernel/sched_downmigrate
chwrite 30 /proc/sys/kernel/sched_upmigrate
fi
fi
echo "* 十核多任务优化已完成" |  tee -a $LOG;
else
if [ $mode = "turbo" ] ; then
chwrite 25 /proc/sys/kernel/sched_downmigrate
chwrite 35 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "balance" ] ; then
chwrite 35 /proc/sys/kernel/sched_downmigrate
chwrite 55 /proc/sys/kernel/sched_upmigrate
elif [ $mode = "powersave" ] ; then
chwrite 50 /proc/sys/kernel/sched_downmigrate
chwrite 70 /proc/sys/kernel/sched_upmigrate
else
chwrite 20 /proc/sys/kernel/sched_downmigrate
chwrite 30 /proc/sys/kernel/sched_upmigrate
fi
echo "* 未知核心多任务优化已完成" |  tee -a $LOG;
fi
if [ $mode = "gamexe" ] ; then
 if [ $game_mode = "1" ] ; then   #限制最高频率以降低功耗及发热
  if [ $SOC = "msm8994" ] ; then  #骁龙810
   chwrite 1440000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite 1440000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
   chwrite 1440000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_max_freq
   chwrite 1440000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_max_freq
  elif [ $SOC = "msm8996" ] ; then   #骁龙820
   chwrite 1880000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_max_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_max_freq
  elif [ $SOC = "msm8998" ] ; then   #骁龙835
   chwrite 1980000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite 1980000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
   chwrite 1980000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_max_freq
   chwrite 1980000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_max_freq
  elif [ $SOC = "sdm660" ] ; then   #骁龙660
   chwrite 1880000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_max_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_max_freq
  elif [ $SOC = "sdm450" ] ; then   #骁龙450
   chwrite 1689000 /sys/devices/system/cpu/cpu0/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu1/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_max_freq
   chwrite 1689000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_max_freq
  elif [ $SOC = "msm8953" ] ; then   #骁龙625 
   chwrite 1680000 /sys/devices/system/cpu/cpu0/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu1/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_max_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_max_freq
  elif [ $SOC = "msm8992" ] ; then   #骁龙808
   chwrite $freq4 /sys/devices/system/cpu/cpu4/cpufreq/cpu_max_freq
   chwrite $freq4 /sys/devices/system/cpu/cpu5/cpufreq/cpu_max_freq
  fi
 else   #限制最低频率以提升性能
  if [ $SOC = "msm8994" ] ; then   #骁龙810
   chwrite 1180000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1180000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq
   chwrite 1180000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_min_freq
   chwrite 1180000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_min_freq
  elif [ $SOC = "msm8996" ] ; then   #骁龙820
   chwrite 1580000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_min_freq
   chwrite 1580000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_min_freq
  elif [ $SOC = "msm8998" ] ; then   #骁龙835
   chwrite 1880000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_min_freq
   chwrite 1880000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_min_freq
  elif [ $SOC = "sdm660" ] ; then   #骁龙660
   chwrite 1680000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_min_freq
   chwrite 1680000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_min_freq
  elif [ $SOC = "sdm450" ] ; then   #骁龙450
   chwrite 1401000 /sys/devices/system/cpu/cpu0/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu1/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_min_freq
   chwrite 1401000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_min_freq
  elif [ $SOC = "msm8953" ] ; then   #骁龙625
   chwrite 1380000 /sys/devices/system/cpu/cpu0/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu1/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu2/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu3/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu6/cpufreq/cpu_min_freq
   chwrite 1380000 /sys/devices/system/cpu/cpu7/cpufreq/cpu_min_freq
  elif [ $SOC = "msm8992" ] ; then   #骁龙808
   chwrite 1440000 /sys/devices/system/cpu/cpu4/cpufreq/cpu_min_freq
   chwrite 1440000 /sys/devices/system/cpu/cpu5/cpufreq/cpu_min_freq  
  fi
 fi
 echo "* Game X Extreme模式CPU频率阈值调整完毕" |  tee -a $LOG;
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
if [ $mode = "gamexe" ] ; then
if [ $game_mode = "2" ] ; then
chwrite 80 /sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 70 sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
else
chwrite 20 /sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 10 sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
fi
echo "* gamexe 模式下Kirin GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "turbo" ] ; then
chwrite 40 /sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 20 sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
echo "* turbo 模式下Kirin GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "balance" ] ; then
chwrite 50 /sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 30 sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
echo "* balance 模式下Kirin GPU优化完毕" |  tee -a $LOG;
elif [ $mode = "powersave" ] ; then
chwrite 80 /sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_upthreshold
chwrite 70 sys/devices/e8600000.mali/devfreq/gpufreq/mali_ondemand/vsync_downdifferential
echo "* powersave 模式下Kirin GPU优化完毕" |  tee -a $LOG;
fi
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
case $SOC in exynos*)
#Exynos
if [ $mode = "gamexe" ] ; then
chwrite 4 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chwrite 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo "* gamexe 模式下Exynos CPU优化完毕" |  tee -a $LOG;
else
chwrite 2 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chwrite 4 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo "* Exynos CPU优化完毕" |  tee -a $LOG;
fi
echo "* Exynos附加优化完毕" |  tee -a $LOG;
esac
case $SOC in moorefield*)
#Intel Atom
chwrite "0:1380000 4:1380000" /sys/module/msm_performance/parameters/cpu_min_freq
set_param $gov_l cpu0 above_hispeed_delay "18000 1680000:198000"
set_param $gov_l cpu0 hispeed_freq 1380000
set_param $gov_l cpu0 target_loads "80 1780000:90"
set_param $gov_l cpu0 min_sample_time 38000
set_param $gov_l cpu$bcores above_hispeed_delay "18000 1680000:198000"
set_param $gov_l cpu$bcores hispeed_freq 1380000
set_param $gov_l cpu$bcores target_loads "80 1780000:90"
set_param $gov_l cpu$bcores min_sample_time 38000
echo "* Intel Atom附加优化完毕" |  tee -a $LOG;
esac
echo "* FastTurbo全舰弹药填装完毕！" |  tee -a $LOG;
#结束程序
exit 0
