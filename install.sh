##########################################################################################
#
# Unity Config Script
# by topjohnwu, modified by Zackptg5
#
##########################################################################################

##########################################################################################
# Unity Logic - Don't change/move this section
##########################################################################################

if [ -z $UF ]; then
  UF=$TMPDIR/common/unityfiles
  unzip -oq "$ZIPFILE" 'common/unityfiles/util_functions.sh' -d $TMPDIR >&2
  [ -f "$UF/util_functions.sh" ] || { ui_print "! Unable to extract zip file !"; exit 1; }
  . $UF/util_functions.sh
fi

comp_check

##########################################################################################
# Config Flags
##########################################################################################

# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maximum android version for your mod
# Uncomment DYNLIB if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment SYSOVER if you want the mod to always be installed to system (even on magisk) - note that this can still be set to true by the user by adding 'sysover' to the zipname
# Uncomment DIRSEPOL if you want sepolicy patches applied to the boot img directly (not recommended) - THIS REQUIRES THE RAMDISK PATCHER ADDON (this addon requires minimum api of 17)
# Uncomment DEBUG if you want full debug logs (saved to /sdcard in magisk manager and the zip directory in twrp) - note that this can still be set to true by the user by adding 'debug' to the zipname
MINAPI=23
#MAXAPI=25
#DYNLIB=true
#SYSOVER=true
#DIRSEPOL=true
#DEBUG=true

# Uncomment if you do *NOT* want Magisk to mount any files for you. Most modules would NOT want to set this flag to true
# This is obviously irrelevant for system installs. This will be set to true automatically if your module has no files in system
#SKIPMOUNT=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example

# Construct your own list here
REPLACE="
/system/bin/thermal-engine
/system/vendor/bin/thermal-engine
/system/vendor/lib/libthermalioctl.so
/system/vendor/lib/libthermalclient.so
/system/vendor/lib64/libthermalioctl.so
/system/vendor/lib64/libthermalclient.so
/product/etc/hwpg/thermald.xml
"

##########################################################################################
# Custom Logic
##########################################################################################

# Set what you want to display when installing your module


#Function
turbo(){
echo "turbo" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "256" > /data/FastTurbo/zmode
echo "mid" > /data/FastTurbo/amode
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
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
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
fi
}
gamexe(){
echo "gamexe" > $mode
if [ -e /data/FastTurbo/zmode ] ; then
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
else
echo "0" > /data/FastTurbo/zmode
echo "max" > /data/FastTurbo/amode
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
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
chmod 0666 /data/FastTurbo/zmode
chmod 0666 /data/FastTurbo/amode
fi
}
keytest() {
  ui_print "** Volume key test **"
  ui_print "** Please press volume + **"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  while true; do
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
    ui_print "**  Volume key not detected **"
    abort "** Please use name change method in TWRP**"
  fi
}

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK
ui_print "************************************"
ui_print "   FastTurbo Boost Installer V2.1   "
ui_print "      Author:Chenzyadb@coolapk      "
ui_print "      Translate:Chinatsu Moss       "
ui_print "************************************"
if [ $API = "29" ] ; then
ui_print "Android Q has not been tested with this module."
fi
#建立目录
ui_print "- Configuring key files..."
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
chmod 0666 /data/FastTurbo/kmode
fi
if [ -e /data/FastTurbo/temp_fix ] ; then
chmod 0666 /data/FastTurbo/temp_fix
else
echo "true" > /data/FastTurbo/temp_fix
chmod 0666 /data/FastTurbo/temp_fix
fi
if [ -e /data/FastTurbo/net_fix ] ; then
chmod 0666 /data/FastTurbo/net_fix
else
echo "true" > /data/FastTurbo/net_fix
chmod 0666 /data/FastTurbo/net_fix
fi
if [ -e /data/FastTurbo/kernel_fix ] ; then
chmod 0666 /data/FastTurbo/kernel_fix
else
echo "true" > /data/FastTurbo/kernel_fix
chmod 0666 /data/FastTurbo/kernel_fix
fi
if [ -e /data/FastTurbo/google_fix ] ; then
chmod 0666 /data/FastTurbo/google_fix
else
echo "true" > /data/FastTurbo/google_fix
chmod 0666 /data/FastTurbo/google_fix
fi
if [ -e /data/FastTurbo/prop_fix ] ; then
chmod 0666 /data/FastTurbo/prop_fix
else
echo "true" > /data/FastTurbo/prop_fix
chmod 0666 /data/FastTurbo/prop_fix
fi
if [ -e /data/FastTurbo/touch_fix ] ; then
chmod 0666 /data/FastTurbo/touch_fix
else
echo "true" > /data/FastTurbo/touch_fix
chmod 0666 /data/FastTurbo/touch_fix
fi
if [ -e /data/FastTurbo/vm_fix ] ; then
chmod 0666 /data/FastTurbo/vm_fix
else
echo "true" > /data/FastTurbo/vm_fix
chmod 0666 /data/FastTurbo/vm_fix
fi
if [ -e /data/FastTurbo/io_fix ] ; then
chmod 0666 /data/FastTurbo/io_fix
else
echo "true" > /data/FastTurbo/io_fix
chmod 0666 /data/FastTurbo/io_fix
fi
if [ -e /data/FastTurbo/lpl_fix ] ; then
chmod 0666 /data/FastTurbo/lpl_fix
else
echo "true" > /data/FastTurbo/lpl_fix
chmod 0666 /data/FastTurbo/lpl_fix
fi
if [ -e /data/FastTurbo/dse_fix ] ; then
chmod 0666 /data/FastTurbo/dse_fix
else
echo "true" > /data/FastTurbo/dse_fix
chmod 0666 /data/FastTurbo/dse_fix
fi

ui_print "- Key files are configured."


sleep 1

  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "** Volume button programming **"
    ui_print " "
    ui_print "** Please press Volume+ again **"
    $FUNCTION "UP"
    ui_print "** Please press Volume- **"
    $FUNCTION "DOWN"
  fi
  #介绍模式
  ui_print "MODE1:Balance"
  ui_print "MODE2:Turbo"
  ui_print "MODE3:Game X Extreme"
  ui_print "MODE4:Powersave"
  ui_print "** Please select the mode **"
  ui_print " "
  ui_print "  Volume(+) = balance"
  ui_print "  Volume(-) = Next & other mode..."
  ui_print " "

  if $FUNCTION; then
    balance
    ui_print "	Balanced Mode selected."
    ui_print " "

  else
  ui_print "** Please select the mode **"
  ui_print " "
  ui_print "   Volume(+) = turbo"
  ui_print "   Volume(-) = Next & other mode..."
  ui_print " "

  if $FUNCTION; then
    turbo
    ui_print "	Turbo Mode selected."
    ui_print " "

  else

  ui_print "** Please select the mode **"
  ui_print " "
  ui_print "   Volume(+) = Game X Extreme"
  ui_print "   Volume(-) = Next & other mode..."
  ui_print " "

  if $FUNCTION; then
    gamexe
    ui_print "	Game X Extreme Mode selected."
    ui_print " "

  else

  ui_print "** Please select the mode **"
  ui_print " "
  ui_print "   Volume(+) = powersave"
  ui_print " "

  if $FUNCTION; then
    powersave
    ui_print "	Powersave Mode selected."
    ui_print " "

  else
    balance
    ui_print "  Wrong input."
    ui_print "  The Balance Mode is selected by default."
    ui_print " "
  fi
  fi
  fi
  fi
 
 

set_permissions() {
  : # Remove this if adding to this function

  # Note that all files/folders have the $UNITY prefix - keep this prefix on all of your files/folders
  # Also note the lack of '/' between variables - preceding slashes are already included in the variables
  # Use $VEN for vendor (Do not use /system$VEN, the $VEN is set to proper vendor path already - could be /vendor, /system/vendor, etc.)

  # Some examples:
  
  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm_recursive $UNITY/system/lib 0 0 0755 0644
  # set_perm_recursive $UNITY$VEN/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm $UNITY/system/lib/libart.so 0 0 0644
}

# Custom Variables for Install AND Uninstall - Keep everything within this function - runs before uninstall/install
unity_custom() {
 :
}

# Custom Functions for Install AND Uninstall - You can put them here
on_install() {
unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
echo $MODPATH > /data/FastTurbo/uninstall_url
}