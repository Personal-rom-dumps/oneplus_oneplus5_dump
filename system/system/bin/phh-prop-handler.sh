#!/system/bin/sh
set -o pipefail

display_usage() {
    echo -e "\nUsage:\n ./phh-prop-handler.sh [prop]\n"
}

if [ "$#" -ne 1 ]; then
    display_usage
    exit 1
fi

prop_value=$(getprop "$1")

xiaomi_toggle_dt2w_proc_node() {
    DT2W_PROC_NODES=("/proc/touchpanel/wakeup_gesture"
        "/proc/tp_wakeup_gesture"
        "/proc/tp_gesture")
    for node in "${DT2W_PROC_NODES[@]}"; do
        [ ! -f "${node}" ] && continue
        echo "Trying to set dt2w mode with /proc node: ${node}"
        echo "$1" >"${node}"
        [[ "$(cat "${node}")" -eq "$1" ]] # Check result
        return
    done
    return 1
}

xiaomi_toggle_dt2w_event_node() {
    for ev in $(
        cd /sys/class/input || return
        echo event*
    ); do
        [ ! -f "/sys/class/input/${ev}/device/device/gesture_mask" ] &&
            [ ! -f "/sys/class/input/${ev}/device/wake_gesture" ] && continue
        echo "Trying to set dt2w mode with event node: /dev/input/${ev}"
        if [ "$1" -eq 1 ]; then
            # Enable
            sendevent /dev/input/"${ev}" 0 1 5
            return
        else
            # Disable
            sendevent /dev/input/"${ev}" 0 1 4
            return
        fi
    done
    return 1
}

if [ "$1" == "persist.sys.phh.xiaomi.dt2w" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    if ! xiaomi_toggle_dt2w_proc_node "$prop_value"; then
        # Fallback to event node method
        xiaomi_toggle_dt2w_event_node "$prop_value"
    fi
    exit $?
fi

if [ "$1" == "persist.sys.phh.oppo.dt2w" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/proc/touchpanel/double_tap_enable
    exit
fi

if [ "$1" == "persist.sys.phh.oppo.gaming_mode" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/proc/touchpanel/game_switch_enable
    exit
fi

if [ "$1" == "persist.sys.phh.oppo.usbotg" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/sys/class/power_supply/usb/otg_switch
    exit
fi

# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# Wait for the system to boot completely
while [[ `getprop sys.boot_completed` -ne 1 ]]
do
       sleep 1
done

# Sleep an additional 120s to ensure init is finished
sleep 120

# Setup tweaks
# MIUI PROPS BY KEIDORIAN @adriansenpai @GITHUB

# Safely apply sysctl adjustment
ctl() {
	# Fetch the current key value
	local curval=`sysctl -e -n "$1"`

	# Bail out if sysctl key does not exist
	if [[ -z "$curval" ]]
	then
		return 1
	fi

	# Bail out if sysctl is already set
	if [[ "$curval" == "$2" ]]
	then
		return 0
	fi

	# Set the new value
	sysctl -w "$1"="$2" &> /dev/null

	# Bail out if write fails
	if [[ $? -ne 0 ]]
	then
		return 1
	fi
}

# Safely write value to file
write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]
	then
		return 1
	fi

	# Fetch the current key value
	local curval=`cat "$1" 2> /dev/null`

	# Bail out if value is already set
	if [[ "$curval" == "$2" ]]
	then
		return 0
	fi

	# Write the new value
	echo "$2" > "$1"

	# Bail out if write fails
	if [[ $? -ne 0 ]]
	then
		return 1
	fi
}

# Permissions
chmod 644 /sys/block/*/queue/nr_requests
chmod 644 /sys/module/workqueue/parameters/power_efficient
chmod 644 /sys/devices/platform/kcal_control.0/kcal
chmod 644 /sys/devices/platform/kcal_control.0/kcal_enable
chmod 644 /sys/devices/system/cpu/cpuidle/use_deepest_state_ro

# More info in the main Magisk thread# Enable Fsync
write /sys/module/sync/parameters/fsync_enabled "Y"

# lowmemkiller
write /sys/module/lowmemorykiller/parameters/minfree "18432,23040,27648,32256,55296,100640" 

# adj
write /sys/module/lowmemorykiller/parameters/adj "0,100,200,300,900,906" 

# Wakelock Blocker
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "qcom_rx_wakelock;wlan;wlan_wow_wl;wlan_extscan_wl;netmgr_wl;NETLINK;IPA_WS;[timerfd];wlan_ipa;wlan_pno_wl;wcnss_filter_lock;IPCRTR_lpass_rx;hal_bluetooth_lock"
settings put global location_background_throttle_interval_ms "1800000"
settings put global wakelock_blocking_enabled "1"
settings put global wakelock_blocking_list "BackgroundTaskService-PhotosUnltdBackupTask|BackgroundTaskService-VideoCompressionScheduleTask|BackgroundTaskService-FetchAccountPropsTask|BackgroundTaskService-UpdateFlagsTask|AnyMotionDetector|BackgroundTaskService-PhotosBackupTask|BackgroundTaskService-RegisterSyncPhenotypeTask|BackgroundTaskService-BackupScheduleTask|*gms_scheduler*/com.google.android.gms/.phenotype.service.sync.PhenotypeConfigurator|wake:com.google.firebase.iid.WakeLockHolder|SyncLoopWakeLock|*job*/com.google.android.syncadapters.contacts/.ContactsSyncAdapterJobIntentService|*gms_scheduler*/com.google.android.gms/.ads.social.GcmSchedulerWakeupService|*gms_scheduler*/com.google.android.gms/.ads.jams.NegotiationService"
           
# Changes kcal setting at Boot
write /sys/devices/platform/kcal_ctrl.0/kcal "220 220 220"
write /sys/devices/platform/kcal_ctrl.0/kcal_enable "1" 
write /sys/devices/platform/kcal_ctrl.0/kcal_sat "265" 
write /sys/devices/platform/kcal_ctrl.0/kcal_val "253"
write /sys/devices/platform/kcal_ctrl.0/kcal_cont "257"
write /sys/devices/platform/kcal_ctrl.0/kcal_min "35"
write /sys/devices/platform/kcal_ctrl.0/kcal_hue "0"

# Scheduler features
if [[ -f "/sys/kernel/debug/sched_features" ]]
then
	write /sys/kernel/debug/sched_features LAST_BUDDY
	write /sys/kernel/debug/sched_features AFFINE_WAKEUPS
	write /sys/kernel/debug/sched_features TTWU_QUEUE
	write /sys/kernel/debug/sched_features NEW_FAIR_SLEEPERS
	write /sys/kernel/debug/sched_features NO_GENTLE_FAIR_SLEEPERS
	write /sys/kernel/debug/sched_features NO_RT_RUNTIME_SHARE
	write /sys/kernel/debug/sched_features WAKEUP_PREEMPTION
fi

# VM
ctl vm.dirty_background_ratio 10
ctl vm.dirty_ratio 25
ctl vm.dirty_expire_centisecs 750
ctl vm.dirty_writeback_centisecs 300
ctl vm.page-cluster 0
ctl vm.reap_mem_on_sigkill 1
ctl vm.stat_interval 10
ctl vm.swappiness 100
ctl vm.vfs_cache_pressure 200

# Kernel
ctl kernel.perf_cpu_time_max_percent 40
ctl kernel.sched_prefer_sync_wakee_to_waker 1
ctl kernel.sched_short_sleep_ns 1000000
ctl kernel.sched_autogroup_enabled 1
ctl kernel.sched_enable_thread_grouping 1
ctl kernel.sched_tunable_scaling 0
ctl kernel.sched_latency_ns 10000000
ctl kernel.sched_min_granularity_ns 1250000
ctl kernel.sched_migration_cost_ns 1000000
ctl kernel.sched_nr_migrate 64
ctl kernel.sched_rt_period_us 1000000
ctl kernel.sched_rt_runtime_us 950000
ctl kernel.sched_schedstats 0
ctl kernel.sched_wakeup_granularity_ns 2000000

for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do

avail_govs=`cat "${cpu}scaling_available_governors"`
	[[ "$avail_govs" == *"interactive"* ]] && write "${cpu}scaling_governor" interactive
	[[ "$avail_govs" == *"schedutil"* ]] && write "${cpu}scaling_governor" schedutil

# Interactive-specific tweaks

	if [[ -d "${cpu}interactive" ]]
	then
                write /sys/devices/system/cpu/cpufreq/policy0/interactive/go_hispeed_load "92"
                write /sys/devices/system/cpu/cpufreq/policy4/interactive/go_hispeed_load "98"
				write /sys/devices/system/cpu/cpufreq/policy0/interactive/min_sample_time "35000"
                write /sys/devices/system/cpu/cpufreq/policy4/interactive/min_sample_time "25000"
                write /sys/module/msm_performance/parameters/touchboost "0"
                write /sys/module/workqueue/parameters/power_efficient "Y"
                write /sys/module/lpm_levels/parameters/sleep_disabled "N"
                write /sys/devices/system/cpu/cpuidle/use_deepest_state "1"
                write /sys/devices/system/cpu/cpuidle/use_deepest_state_ro "1"
	fi
	
	# Schedutil-specific tweaks
	if [[ -d "${cpu}schedutil" ]]
	then
		write "${cpu}schedutil/up_rate_limit_us" 10000
		write "${cpu}schedutil/down_rate_limit_us" 10000
		write "${cpu}schedutil/rate_limit_us" 10000
        write /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq "902400"
        write /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq "1401600"
		write /sys/devices/system/cpu/cpufreq/policy0/schedutil/go_hispeed_load "90"
        write /sys/devices/system/cpu/cpufreq/policy4/schedutil/go_hispeed_load "95"
        write /sys/module/workqueue/parameters/power_efficient "Y"
        write /sys/module/lpm_levels/parameters/sleep_disabled "N"
        write /sys/devices/system/cpu/cpuidle/use_deepest_state "1"
        write /sys/devices/system/cpu/cpuidle/use_deepest_state_ro "1"
	fi
done

# CAF CPU boost
if [[ -d "/sys/module/cpu_boost" ]]
then
	write "/sys/module/cpu_boost/parameters/input_boost_freq" 0:1401600
	write "/sys/module/cpu_boost/parameters/input_boost_ms" 50
fi

# I/O
for queue in /sys/block/*/queue/
do
    write "${queue}scheduler" cfq
	write "${queue}scheduler" none
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 64
	write /sys/block/mmcblk0/queue/read_ahead_kb "128"
	write /sys/block/mmcblk0/*/queue/read_ahead_kb "128"
	write /sys/block/dm-0/queue/read_ahead_kb "128"
	write "${queue}nr_requests" 256
done

# Sched Tweaks
for sched in /sys/block/*/queue/iosched/
do
write "${sched}back_seek_max" 16384
write "${sched}back_seek_penalty" 2
write "${sched}fifo_expire_async" 250
write "${sched}fifo_expire_sync" 125
write "${sched}low_latency" 1
write "${sched}slice_async" 40
write "${sched}slice_async_rq" 2
write "${sched}slice_async_us" 40000
write "${sched}slice_idle" 8
write "${sched}slice_idle_us" 8000
write "${sched}slice_sync" 100
write "${sched}slice_sync_us" 100000
write "${sched}target_latency" 300
write "${sched}target_latency_us" 300000
done

# Optimizations
setprop persist.sys.use_dithering 0
setprop wifi.supplicant_scan_interval 180
setprop vendor.perf.gestureflingboost.enable false
write /sys/power/autosleep "mem"
write /sys/power/mem_sleep "deep"
su -c "pm disable com.google.android.apps.wellbeing/.powerstate.impl.PowerStateJobService"
su -c "pm disable com.google.android.apps.wellbeing/androidx.work.impl.background.systemjob.SystemJobService"
su -c "pm disable com.facebook.katana/com.facebook.analytics.appstatelogger.AppStateIntentService"
su -c "pm disable com.facebook.orca/com.facebook.analytics.apptatelogger.AppStateIntentService"
su -c "pm disable com.facebook.orca/com.facebook.analytics2.Logger.LollipopUploadService"

# better idling
echo 0-3 > /dev/cpuset/restricted/cpus

for cod in /data/data/com.tencent.tmgp.sgame/shared_prefs/
do
# com.tencent.tmgp.sgame
if [[ -d "${cod}com.tencent.tmgp.sgame.v2.playerprefs.xml" ]] then
File=/data/data/com.tencent.tmgp.sgame/shared_prefs/com.tencent.tmgp.sgame.v2.playerprefs.xml

sed -i '/.*<int name="VulkanTryCount" value=".*" \/>/'d "$File"
sed -i '/.*<int name="EnableVulkan" value=".*" \/>/'d "$File"
sed -i '/.*<int name="EnableGLES3" value=".*" \/>/'d "$File"
sed -i '/.*<int name="EnableMTR" value=".*" \/>/'d "$File"
sed -i '/.*<int name="DisableMTR" value=".*" \/>/'d "$File"
sed -i '2a \ \ \ \ <int name="VulkanTryCount" value="1" \/>' "$File";
sed -i '3a \ \ \ \ <int name="EnableVulkan" value="3" \/>' "$File";
sed -i '4a \ \ \ \ <int name="EnableGLES3" value="1" \/>' "$File";
sed -i '5a \ \ \ \ <int name="EnableMTR" value="1" \/>' "$File";
sed -i '6a \ \ \ \ <int name="DisableMTR" value="3" \/>' "$File";
fi
done

# Disable collective Device administrators
su -c "pm disable com.google.android.gms/com.google.android.gms.auth.managed.admin.DeviceAdminReceiver"
su -c "pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"

# Doze setup services;
su -c "pm enable com.google.android.gms/.ads.AdRequestBrokerService"
su -c "pm enable com.google.android.gms/.ads.identifier.service.AdvertisingIdService"
su -c "pm enable com.google.android.gms/.ads.social.GcmSchedulerWakeupService"
su -c "pm enable com.google.android.gms/.analytics.AnalyticsService"
su -c "pm enable com.google.android.gms/.analytics.service.PlayLogMonitorIntervalService"
su -c "pm enable com.google.android.gms/.backup.BackupTransportService"
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService\$ActiveReceiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService\$Receiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService\$SecretCodeReceiver"
su -c "pm enable com.google.android.gms/.thunderbird.settings.ThunderbirdSettingInjectorService"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService\$Receiver"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService\$SecretCodeReceiver"
su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.bootstrap.service.NearbyBootstrapService"
su -c "pm disable com.google.android.gms/NearbyMessagesService"
su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.connection.service.NearbyConnectionsAndroidService"
su -c "pm disable com.google.android.gms/com.google.location.nearby.direct.service.NearbyDirectService"

exit 0

