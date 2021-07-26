#!/system/bin/sh

[ "$(getprop vold.decrypt)" = "trigger_restart_min_framework" ] && exit 0

for i in wpa p2p;do
	if [ ! -f /data/misc/wifi/${i}_supplicant.conf ];then
		cp /vendor/etc/wifi/wpa_supplicant.conf /data/misc/wifi/${i}_supplicant.conf
	fi
	chmod 0660 /data/misc/wifi/${i}_supplicant.conf
	chown wifi:system /data/misc/wifi/${i}_supplicant.conf
done

if grep -qF android.hardware.boot /vendor/manifest.xml || grep -qF android.hardware.boot /vendor/etc/vintf/manifest.xml ;then
	bootctl mark-boot-successful
fi

setprop ctl.restart sec-light-hal-2-0
if find /sys/firmware -name support_fod |grep -qE .;then
	setprop ctl.restart vendor.fps_hal
fi

#Clear looping services
sleep 30
getprop | \
    grep restarting | \
    sed -nE -e 's/\[([^]]*).*/\1/g'  -e 's/init.svc.(.*)/\1/p' |
    while read -r svc ;do
        setprop ctl.stop "$svc"
    done
    
# Author is @Zerux31
# Credits to Draco (tytydraco @ GitHub)
# Wait for boot to finish completely
while [[ `getprop sys.boot_completed` -ne 1 ]] && [[ ! -d "/sdcard" ]]
do
       sleep 1
done

# Sleep an additional 120s to ensure init is finished
sleep 120

# Run the script
stop logd
stop statsd
stop traced
for i in /sys/block/*/queue/iostats
do
echo 0 > $i
done
for i in /sys/block/*/queue/nr_requests
do
echo 64 > $i
done
for i in /sys/block/*/bdi/max_ratio
do
echo 0 > $i
done
for i in /sys/block/*/bdi/read_ahead_kb
do
echo 128 > $i
done
for i in /sys/block/*/queue/read_ahead_kb
do
echo 256 > $i
done
for i in /sys/block/*/queue/rq_affinity
do
echo 1 > $i
done
for i in /sys/block/*/queue/nomerges 
do
echo 2 > $i
done
for i in /sys/block/*/queue/add_random
do
echo 1 > $i
done
for i in /sys/dev/block/*/queue/iostats
do
echo 0 > $i
done
for i in /sys/dev/block/*/queue/nr_requests
do
echo 64 > $i
done
for i in /sys/dev/block/*/bdi/max_ratio
do
echo 0 > $i
done
for i in /sys/dev/block/*/bdi/read_ahead_kb
do
echo 128 > $i
done
for i in /sys/dev/block/*/queue/read_ahead_kb
do
echo 256 > $i
done
for i in /sys/dev/block/*/queue/rq_affinity
do
echo 1 > $i
done
for i in /sys/dev/block/*/queue/nomerges 
do
echo 2 > $i
done
for i in /sys/dev/block/*/queue/add_random
do
echo 1 > $i
done
for i in /sys/devices/virtual/block/*/queue/iostats
do
echo 0 > $i
done
for i in /sys/devices/virtual/block/*/queue/nr_requests
do
echo 64 > $i
done
for i in /sys/devices/virtual/block/*/bdi/max_ratio
do
echo 0 > $i
done
for i in /sys/devices/virtual/block/*/queue/read_ahead_kb
do
echo 256 > $i
done
for i in /sys/devices/virtual/block/*/bdi/read_ahead_kb
do
echo 128 > $i
done
for i in /sys/devices/virtual/block/*/queue/rq_affinity
do
echo 1 > $i
done
for i in /sys/devices/virtual/block/*/queue/nomerges
do
echo 2 > $i
done
for i in /sys/devices/virtual/block/*/queue/add_random
do
echo 1 > $i
done
for i in /sys/devices/virtual/bdi/*/max_ratio
do
echo 0 > $i
done
for i in /sys/devices/virtual/bdi/*/read_ahead_kb
do
echo 128 > $i
done
for i in /sys/block/*/queue/iosched/target_latency
do
echo 1 > $i
done
for i in /sys/block/*/queue/iosched/target_latency_us
do
echo 1 > $i
done
for i in /sys/kernel/tracing/per_cpu/*/buffer_size_kb
do
echo 0 > $i
done
echo 0 > /sys/kernel/tracing/buffer_size_kb
echo 0 > /sys/kernel/tracing/buffer_total_size_kb
for i in /sys/class/block/*/queue/iostats
do
echo 0 > $i
done
for i in /sys/class/block/*/queue/nr_requests
do
echo 256 > $i
done
for i in /sys/class/block/*/bdi/max_ratio
do
echo 0 > $i
done
for i in /sys/class/block/*/bdi/read_ahead_kb
do
echo 256 > $i
done
for i in /sys/class/block/*/queue/read_ahead_kb
do
echo 256 > $i
done
for i in /sys/class/block/*/queue/rq_affinity
do
echo 2 > $i
done
for i in /sys/class/block/*/queue/nomerges 
do
echo 2 > $i
done
for i in /sys/class/block/*/queue/add_random
do
echo 1 > $i
done
for i in /sys/class/block/*/queue/iosched/target_latency
do
echo 1 > $i
done
for i in /sys/class/block/*/queue/iosched/target_latency_us
do
echo 1 > $i
done
echo 3 > /proc/sys/vm/drop_caches
echo 0 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/pmqos_active_latency
echo 100 /sys/class/kgsl/kgsl-3d0/devfreq/gpu_load
for i in /sys/bus/cpu/devices/*/cpuidle/*/disable
do
echo 1 > $i
done
for i in /sys/bus/cpu/devices/*/cpufreq/schedutil/hispeed_load
do
echo 100 > $i
done
echo "-1" > /sys/fs/cgroup/memory/memory.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.usage_in_bytes
echo 30 > /sys/fs/cgroup/memory/memory.swappiness
echo "-1" > /sys/fs/cgroup/memory/apps/memory.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.usage_in_bytes
echo 30 > /sys/fs/cgroup/memory/apps/memory.swappiness
echo "-1" > /sys/fs/cgroup/memory/system/memory.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.usage_in_bytes
echo 30 > /sys/fs/cgroup/memory/system/memory.swappiness
echo "-1" > /sys/fs/cgroup/memory/memory.kmem.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.kmem.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.kmem.tcp.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.memsw.usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/memory.soft_limit_in_bytes
echo "0" > /sys/fs/cgroup/memory/memory.use_hierarchy
echo "-1" > /sys/fs/cgroup/memory/apps/memory.kmem.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.kmem.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.kmem.tcp.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.memsw.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.memsw.usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/apps/memory.soft_limit_in_bytes
echo "0" > /sys/fs/cgroup/memory/apps/memory.use_hierarchy
echo "-1" > /sys/fs/cgroup/memory/system/memory.kmem.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.kmem.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.kmem.tcp.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.max_usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.memsw.limit_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.memsw.usage_in_bytes
echo "-1" > /sys/fs/cgroup/memory/system/memory.soft_limit_in_bytes
echo "0" > /sys/fs/cgroup/memory/system/memory.use_hierarchy
echo 0 > /proc/sys/vm/extra_free_kbytes
echo 200 > /proc/sys/vm/extfrag_threshold
echo 8192 > /proc/sys/vm/min_free_kbytes
echo 0 > /proc/sys/debug/exception-trace 
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo 0 > /proc/sys/vm/oom_dump_tasks
echo "N" > /sys/kernel/debug/debug_enabled
echo 0 > /proc/sys/vm/block_dump 
echo 0 > /sys/module/subsystem_restart/parameters/enable_ramdumps
echo 0 > /sys/module/lowmemorykiller/parameters/debug_level
echo 4 > /proc/sys/vm/stat_interval
echo 0 > /proc/sys/vm/page-cluster
echo 0 > /proc/sys/fs/dir-notify-enable
echo 25 > /proc/sys/vm/swappiness
echo 90 > /proc/sys/vm/vfs_cache_pressure
echo 30 > /proc/sys/vm/dirty_ratio
echo 0 > /proc/sys/vm/compact_unevictable_allowed
echo 15 > /proc/sys/vm/dirty_background_ratio
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 2000 > /proc/sys/vm/dirty_writeback_centisecs
echo 1 > /proc/sys/vm/overcommit_memory
echo 10 > /proc/sys/vm/overcommit_ratio
echo 0 > /sys/module/process_reclaim/parameters/enable_process_reclaim
echo 1 > /proc/sys/vm/reap_mem_on_sigkill  
echo 0 > /proc/sys/kernel/kptr_restrict
echo 60 > /proc/sys/kernel/panic
echo 0 > /proc/sys/kernel/real-root-dev
echo 0 > /proc/sys/kernel/randomize_va_space
echo 1 > /proc/sys/kernel/panic_on_oops
echo 1 > /proc/sys/kernel/ctrl-alt-del
echo 0 > /proc/sys/kernel/modules_disabled
echo 65534 > /proc/sys/kernel/overflowgid
echo 65534 > /proc/sys/kernel/overflowuid
echo 0 > /proc/sys/kernel/perf_cpu_time_max_percent
echo 2 > /proc/sys/kernel/perf_event_paranoid
setprop vendor.iop.enable_uxe 1
setprop vendor.perf.iop_v3.enable true
setprop vendor.perf.gestureflingboost.enable "true"
setprop vendor.perf.workloadclassifier.enable "true"
setprop debug.composition.type "c2d"
setprop persist.hwc.mdpcomp.enable "true"
setprop persist.mdpcomp.4k2kSplit "1"
setprop persist.hwc.mdpcomp.maxpermixer "5"
setprop persist.mdpcomp_perfhint "50"
setprop debug.mdpcomp.logs "0"
setprop persist.metadata_dynfps.disable "true"
setprop persist.hwc.ptor.enable "true"
echo "0,1,2,7,14,15" > /sys/module/lowmemorykiller/parameters/adj
for i in /sys/fs/ext4/*/err_ratelimit_interval_ms
do
echo 1250 > $i
done
for i in /sys/fs/ext4/*/warning_ratelimit_interval_ms
do
echo 1250 > $i
done
for i in /sys/fs/ext4/*/msg_ratelimit_interval_ms
do
echo 1250 > $i
done
echo 250 > /sys/module/cpu_boost/parameters/input_boost_ms
echo 1 > /proc/sys/kernel/sched_autogroup_enabled
echo 1 > /proc/sys/kernel/sched_enable_thread_grouping
echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 0 > /proc/sys/kernel/sched_tunable_scaling
echo 3000000 > /proc/sys/kernel/sched_latency_ns
echo 4000000 > /proc/sys/kernel/sched_min_granularity_ns
echo 1000000 > /proc/sys/kernel/sched_migration_cost_ns
echo 10 > /proc/sys/kernel/sched_min_task_util_for_boost
echo 5 > /proc/sys/kernel/sched_min_task_util_for_colocation
echo 32 > /proc/sys/kernel/sched_nr_migrate
echo 0 > /proc/sys/kernel/sched_schedstats
echo 5000000 > /proc/sys/kernel/sched_wakeup_granularity_ns
echo 1 > /proc/sys/kernel/timer_migration
echo 128 > /proc/sys/kernel/random/read_wakeup_threshold
echo 512 > /proc/sys/kernel/random/write_wakeup_threshold
echo 0 > /proc/sys/kernel/sched_boost
echo 10 > /sys/class/thermal/thermal_message/sconfig
for i in /sys/class/thermal/*/cdev0_lower_limit
do
echo 0 > $i
done
for i in /sys/class/thermal/*/cdev0_upper_limit
do
echo 0 > $i
done
for i in /sys/class/thermal/*/cdev1_lower_limit
do
echo 0 > $i
done
for i in /sys/class/thermal/*/cdev1_upper_limit
do
echo 0 > $i
done
for i in /sys/bus/cpu/devices/*/sched_load_boost
do
echo 15 > $i
done
for i in /proc/*/sched_init_task_load
do
echo 0 > $i
done
echo 255 > /proc/sys/kernel/sched_lib_mask_force
echo 25 > /proc/sys/fs/lease-break-time
echo 30 > /proc/sys/kernel/sched_rr_timeslice_ms                                                 
echo 0-5,6-7 > /dev/cpuset/foreground/cpus
echo 0 > /dev/cpuset/restricted/cpus         
echo 0 > /sys/module/binder/parameters/debug_mask
for i in /proc/irq/*/smp_affinity
do
echo "ff" > $i
done
for i in /dev/cpuset/*/cpus
do
echo "0-5,6-7" > $i
done
echo "0-5,6-7" > /dev/cpuset/cpus
for i in /dev/cpuset/*/cpu_exclusive
do
echo 1 > $i
done
for i in /dev/cpuset/*/mem_exclusive
do
echo 1 > $i
done
echo 1 > /dev/cpuset/memory_pressure_enabled
echo 90 > /dev/cpuset/memory_pressure
for i in /dev/cpuset/*/memory_pressure
do
echo 90 > $i
done
for i in /dev/stune/*/schedtune.boost
do
echo 100 > $i
done
for i in /dev/stune/*/schedtune.sched_boost_no_override
do
echo 1 > $i
done
for i in /dev/stune/*/schedtune.colocate
do
echo 1 > $i
done
echo 1 > /dev/stune/schedtune.colocate
echo 1 > /dev/stune/schedtune.sched_boost_no_override
echo 1 > /dev/stune/schedtune.boost
echo "-1" > /dev/memcg/memory.limit_in_bytes
echo "-1" > /dev/memcg/memory.usage_in_bytes
echo 30 > /dev/memcg/memory.swappiness
echo "-1" > /dev/memcg/apps/memory.limit_in_bytes
echo "-1" > /dev/memcg/apps/memory.usage_in_bytes
echo 30 > /dev/memcg/apps/memory.swappiness
echo "-1" > /dev/memcg/system/memory.limit_in_bytes
echo "-1" > /dev/memcg/system/memory.usage_in_bytes
echo 30 > /dev/memcg/system/memory.swappiness
echo "-1" > /dev/memcg/memory.kmem.limit_in_bytes
echo "-1" > /dev/memcg/memory.kmem.max_usage_in_bytes
echo "-1" > /dev/memcg/memory.kmem.tcp.limit_in_bytes
echo "-1" > /dev/memcg/memory.max_usage_in_bytes
echo "-1" > /dev/memcg/memory.memsw.limit_in_bytes
echo "-1" > /dev/memcg/memory.memsw.usage_in_bytes
echo "-1" > /dev/memcg/memory.soft_limit_in_bytes
echo "0" > /dev/memcg/memory.use_hierarchy
echo "-1" > /dev/memcg/apps/memory.kmem.limit_in_bytes
echo "-1" > /dev/memcg/apps/memory.kmem.max_usage_in_bytes
echo "-1" > /dev/memcg/apps/memory.kmem.tcp.limit_in_bytes
echo "-1" > /dev/memcg/apps/memory.max_usage_in_bytes
echo "-1" > /dev/memcg/apps/memory.memsw.limit_in_bytes
echo "-1" > /dev/memcg/apps/memory.memsw.usage_in_bytes
echo "-1" > /dev/memcg/apps/memory.soft_limit_in_bytes
echo "0" > /dev/memcg/apps/memory.use_hierarchy
echo "-1" > /dev/memcg/system/memory.kmem.limit_in_bytes
echo "-1" > /dev/memcg/system/memory.kmem.max_usage_in_bytes
echo "-1" > /dev/memcg/system/memory.kmem.tcp.limit_in_bytes
echo "-1" > /dev/memcg/system/memory.max_usage_in_bytes
echo "-1" > /dev/memcg/system/memory.memsw.limit_in_bytes
echo "-1" > /dev/memcg/system/memory.memsw.usage_in_bytes
echo "-1" > /dev/memcg/system/memory.soft_limit_in_bytes
echo "0" > /dev/memcg/system/memory.use_hierarchy

