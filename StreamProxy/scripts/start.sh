#!/system/bin/sh
cd ${0%/*} # current working directory
# source files
source "$(pwd)/settings.ini"

proxy_service() {
  if [[ ! -f "${module_dir}/disable" ]]; then
    $(pwd)/StreamProxy.service enable >/dev/null 2>&1
  else
    toast "Module Disabled"
  fi
}

net_inotifyd() {
  while [[ ! -f /data/misc/net/rt_tables ]]; do
    sleep 3
  done

  net_dir="/data/misc/net"

  for PID in "${PIDs[@]}"; do
    if grep -q "$(pwd)/net.inotify" "/proc/$PID/cmdline"; then
      return
    fi
  done
  inotifyd "$(pwd)/net.inotify" "${net_dir}" >/dev/null 2>&1 &
}

start_inotifyd() {
  PIDs=($(busybox pidof inotifyd)) # Environment variables are required.
  net_inotifyd
  for PID in "${PIDs[@]}"; do
    if grep -q "$(pwd)/StreamProxy.inotify" "/proc/$PID/cmdline"; then
      return
    fi
  done
  inotifyd "$(pwd)/StreamProxy.inotify" "${module_dir}" >/dev/null 2>&1 &
}

proxy_service
start_inotifyd

# Last edited: 2025.12.23
